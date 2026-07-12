import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyStorageService {
  static const String _storageKey = 'emergency_clicks_data';

  // Helper to get formatted local date (timezone safe - Lima, Peru/device timezone)
  static String _getLocalTodayString() {
    final localDateTime = DateTime.now().toLocal();
    final year = localDateTime.year;
    final month = localDateTime.month.toString().padLeft(2, '0');
    final day = localDateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // 1. Record click: Increment locally and trigger background sync
  static Future<void> recordClick() async {
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
        currentEntry['times_clicked'] = (currentEntry['times_clicked'] as int? ?? 0) + 1;
        currentEntry['synced'] = false;
        localMap[todayStr] = currentEntry;
      } else {
        localMap[todayStr] = {
          'times_clicked': 1,
          'synced': false,
        };
      }

      // Save back to local storage
      await prefs.setString(_storageKey, jsonEncode(localMap));
      debugPrint('Local emergency click incremented: $todayStr -> ${localMap[todayStr]['times_clicked']}');

      // Attempt background sync
      await syncPendingData();
    } catch (e) {
      debugPrint('Error in recordClick: $e');
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
            await Supabase.instance.client.from('emergency_clicks').upsert({
              'user_id': user.id,
              'click_date': dateStr,
              'times_clicked': entry['times_clicked'],
            });

            entry['synced'] = true;
            localMap[dateStr] = entry;
            hasChanges = true;
            debugPrint('Successfully synced emergency clicks for $dateStr.');
          } catch (dbError) {
            // Keep synced as false so it retries on next connection state change
            debugPrint('Failed database sync for emergency date $dateStr: $dbError');
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
}
