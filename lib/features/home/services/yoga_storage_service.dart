import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class YogaStorageService {
  static const String _storageKey = 'yoga_practice_data';

  // Helper to get formatted local date (timezone safe - Lima, Peru/device timezone)
  static String _getLocalTodayString() {
    final localDateTime = DateTime.now().toLocal();
    final year = localDateTime.year;
    final month = localDateTime.month.toString().padLeft(2, '0');
    final day = localDateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // 1. Record practice: Increment locally and trigger background sync
  static Future<void> recordPractice() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _getLocalTodayString();

      // Read local history map
      final localDataRaw = prefs.getString(_storageKey) ?? '{}';
      final Map<String, dynamic> localMap = Map<String, dynamic>.from(jsonDecode(localDataRaw));

      // Update local count for today
      if (localMap.containsKey(todayStr)) {
        final currentEntry = Map<String, dynamic>.from(localMap[todayStr]);
        currentEntry['times_practiced'] = (currentEntry['times_practiced'] as int? ?? 0) + 1;
        currentEntry['synced'] = false;
        localMap[todayStr] = currentEntry;
      } else {
        localMap[todayStr] = {
          'times_practiced': 1,
          'synced': false,
        };
      }

      // Save back to local storage
      await prefs.setString(_storageKey, jsonEncode(localMap));
      debugPrint('Local practice incremented: $todayStr -> ${localMap[todayStr]['times_practiced']}');

      // Attempt background sync
      await syncPendingData();
    } catch (e) {
      debugPrint('Error in recordPractice: $e');
    }
  }

  // 2. Synchronize all unsynced data to Supabase
  static Future<void> syncPendingData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('Sync aborted: User is not authenticated.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final localDataRaw = prefs.getString(_storageKey) ?? '{}';
      final Map<String, dynamic> localMap = Map<String, dynamic>.from(jsonDecode(localDataRaw));

      bool hasChanges = false;

      // Find and upload pending entries
      for (final dateStr in localMap.keys) {
        final entry = Map<String, dynamic>.from(localMap[dateStr]);
        if (entry['synced'] == false) {
          try {
            await Supabase.instance.client.from('yoga_practice_history').upsert({
              'user_id': user.id,
              'practice_date': dateStr,
              'times_practiced': entry['times_practiced'],
            });

            entry['synced'] = true;
            localMap[dateStr] = entry;
            hasChanges = true;
            debugPrint('Successfully synced yoga practice for $dateStr.');
          } catch (dbError) {
            // Keep synced as false so it retries on next connection state change
            debugPrint('Failed database sync for date $dateStr: $dbError');
          }
        }
      }

      if (hasChanges) {
        await prefs.setString(_storageKey, jsonEncode(localMap));
      }
    } catch (e) {
      debugPrint('Error in syncPendingData: $e');
    }
  }

  // 3. Get amount of unique days practiced (timezone safe)
  static Future<int> getDaysPracticed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localDataRaw = prefs.getString(_storageKey) ?? '{}';
      final Map<String, dynamic> localMap = jsonDecode(localDataRaw);
      return localMap.keys.length;
    } catch (e) {
      debugPrint('Error in getDaysPracticed: $e');
      return 0;
    }
  }

  // 4. Get total times postures were practiced (clicked) across all days
  static Future<int> getTotalSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localDataRaw = prefs.getString(_storageKey) ?? '{}';
      final Map<String, dynamic> localMap = jsonDecode(localDataRaw);

      int sum = 0;
      for (final val in localMap.values) {
        if (val is Map) {
          sum += (val['times_practiced'] as int? ?? 0);
        }
      }
      return sum;
    } catch (e) {
      debugPrint('Error in getTotalSessions: $e');
      return 0;
    }
  }
}
