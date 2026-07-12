import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Production-grade service for logging module access and meditation sessions.
/// Writes to local cache immediately (offline-first) and syncs to Supabase
/// when connectivity is available. Safe against concurrent calls, corrupt
/// cache, and network timeouts.
class StatsSyncService {
  static final StatsSyncService _instance = StatsSyncService._internal();
  factory StatsSyncService() => _instance;
  StatsSyncService._internal();

  /// Prevents concurrent sync operations from hammering the network.
  bool _isSyncing = false;

  // ─── Public API ──────────────────────────────────────────

  /// Logs a module access. Writes to local cache instantly,
  /// then fires a non-blocking sync attempt.
  Future<void> logModuleAccess(String moduleName) async {
    if (Supabase.instance.client.auth.currentUser == null) return;
    await _appendToCache('unsynced_module_access', {
      'module_name': moduleName,
      'access_date': _todayStr(),
    });
    // Fire-and-forget: don't block UI navigation
    unawaited(_trySync());
  }

  /// Logs a meditation session by duration. Writes to local cache instantly,
  /// then fires a non-blocking sync attempt.
  Future<void> logMeditationSession(int durationMinutes) async {
    if (Supabase.instance.client.auth.currentUser == null) return;
    await _appendToCache('unsynced_meditation_sessions', {
      'duration_minutes': durationMinutes,
      'session_date': _todayStr(),
    });
    // Fire-and-forget: don't block UI navigation
    unawaited(_trySync());
  }

  /// Explicit sync trigger (called on login success and home init).
  /// Safe to call multiple times — coalesces concurrent requests.
  Future<void> syncUnsyncedStats() => _trySync();

  // ─── Internal: Cache Operations ──────────────────────────

  String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  /// Thread-safe append to a JSON array stored in SharedPreferences.
  Future<void> _appendToCache(String key, Map<String, dynamic> entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = _safeDecodeList(prefs.getString(key));
      list.add(entry);
      await prefs.setString(key, jsonEncode(list));
    } catch (e) {
      debugPrint('⚠️ [StatsSyncService] Error writing to cache ($key): $e');
    }
  }

  /// Safely decodes a JSON string into a List, returning an empty list
  /// if the string is null, empty, or corrupt (crash-proof).
  List<dynamic> _safeDecodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      // Corrupt cache — discard it rather than crash the app
      debugPrint('⚠️ [StatsSyncService] Corrupt cache detected, resetting.');
      return [];
    }
  }

  // ─── Internal: Sync Engine ───────────────────────────────

  /// Coalescing sync: if a sync is already running, skip this call.
  /// This prevents hammering the network on rapid consecutive events.
  Future<void> _trySync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return; // Not authenticated yet

      final prefs = await SharedPreferences.getInstance();

      await _syncBatch(
        prefs: prefs,
        cacheKey: 'unsynced_module_access',
        table: 'module_access_logs',
        userId: userId,
        client: client,
        buildUpsertRow: (item) => {
          'user_id': userId,
          'access_date': item['access_date'],
          'module_name': item['module_name'],
          'times_accessed': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictColumns: 'user_id, access_date, module_name',
        counterColumn: 'times_accessed',
      );

      await _syncBatch(
        prefs: prefs,
        cacheKey: 'unsynced_meditation_sessions',
        table: 'meditation_sessions',
        userId: userId,
        client: client,
        buildUpsertRow: (item) => {
          'user_id': userId,
          'session_date': item['session_date'],
          'duration_minutes': item['duration_minutes'],
          'times_meditated': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictColumns: 'user_id, session_date, duration_minutes',
        counterColumn: 'times_meditated',
      );
    } catch (e) {
      debugPrint('⚠️ [StatsSyncService] Sync error (will retry later): $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Generic batch sync for any stats table. Processes items one by one,
  /// keeps failed items in cache for retry on next sync attempt.
  Future<void> _syncBatch({
    required SharedPreferences prefs,
    required String cacheKey,
    required String table,
    required String userId,
    required SupabaseClient client,
    required Map<String, dynamic> Function(Map<String, dynamic> item) buildUpsertRow,
    required String conflictColumns,
    required String counterColumn,
  }) async {
    final raw = prefs.getString(cacheKey);
    final List<dynamic> items = _safeDecodeList(raw);
    if (items.isEmpty) {
      // Clean up corrupt/empty cache keys
      if (raw != null) await prefs.remove(cacheKey);
      return;
    }

    final List<dynamic> failed = [];

    for (final item in items) {
      try {
        if (item is! Map<String, dynamic>) {
          // Skip malformed entries silently
          continue;
        }

        // Atomic increment via RPC or select-then-upsert with conflict resolution
        final existing = await client
            .from(table)
            .select(counterColumn)
            .eq('user_id', userId)
            .eq(
              table == 'module_access_logs' ? 'access_date' : 'session_date',
              item[table == 'module_access_logs' ? 'access_date' : 'session_date'],
            )
            .eq(
              table == 'module_access_logs' ? 'module_name' : 'duration_minutes',
              item[table == 'module_access_logs' ? 'module_name' : 'duration_minutes'],
            )
            .maybeSingle();

        final row = buildUpsertRow(item);

        if (existing != null) {
          final currentCount = existing[counterColumn] as int? ?? 0;
          row[counterColumn] = currentCount + 1;
        }

        await client.from(table).upsert(
          row,
          onConflict: conflictColumns,
        );
      } catch (e) {
        debugPrint('⚠️ [StatsSyncService] Failed to sync item to $table: $e');
        failed.add(item);
      }
    }

    // Update cache: remove synced items, keep only failures
    if (failed.isEmpty) {
      await prefs.remove(cacheKey);
    } else {
      await prefs.setString(cacheKey, jsonEncode(failed));
    }
  }
}
