import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion_entry.dart';

class EmotionStorage {
  static final _supabase = Supabase.instance.client;

  static Future<void> saveEmotion(String date, EmotionType emotion) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Save locally first
    await _saveLocalEmotion(date, emotion);
    await _addUnsyncedDate(date);

    try {
      await _supabase.from('emotion_entries').upsert({
        'user_id': userId,
        'entry_date': date,
        'emotion': emotion.name,
      }, onConflict: 'user_id, entry_date');
      
      // Successfully synced
      await _removeUnsyncedDate(date);
    } catch (_) {
      // Offline mode: quietly keep in unsynced queue, don't throw exception
    }
  }

  /// Get all emotions for a given month with local cache support
  static Future<Map<String, EmotionType>> getEmotionsForMonth(int year, int month) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final firstDay = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = '$year-${month.toString().padLeft(2, '0')}-${DateTime(year, month + 1, 0).day}';

    // First load from local SharedPreferences cache
    final Map<String, EmotionType> localEmotions = await _loadLocalEmotionsForMonth(year, month);

    try {
      final List<dynamic> data = await _supabase
          .from('emotion_entries')
          .select('entry_date, emotion')
          .eq('user_id', userId)
          .gte('entry_date', firstDay)
          .lte('entry_date', lastDay);

      final Map<String, EmotionType> remoteEmotions = {};
      for (var item in data) {
        final date = item['entry_date'] as String;
        final emotionName = item['emotion'] as String;
        final emotionType = EmotionType.values.firstWhere(
          (e) => e.name == emotionName,
          orElse: () => EmotionType.happy,
        );
        remoteEmotions[date] = emotionType;
        
        // Update local cache
        await _saveLocalEmotion(date, emotionType);
      }
      
      // Try to sync any unsynced local emotions in background
      _syncUnsyncedEmotions();

      // Merge remote with local unsynced ones (unsynced has priority because it is the most recent local change)
      final merged = {...remoteEmotions};
      final unsynced = await _getUnsyncedDates();
      for (var date in unsynced) {
        if (localEmotions.containsKey(date)) {
          merged[date] = localEmotions[date]!;
        }
      }
      return merged;
    } catch (_) {
      // Offline fallback: return local cached emotions
      return localEmotions;
    }
  }

  // --- Local Offline Caching Helpers ---

  static Future<Map<String, EmotionType>> _loadLocalEmotionsForMonth(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, EmotionType> result = {};
    
    // Loop through days of the month to find cached ones
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final savedName = prefs.getString('local_emotion_$dateStr');
      if (savedName != null) {
        result[dateStr] = EmotionType.values.firstWhere(
          (e) => e.name == savedName,
          orElse: () => EmotionType.happy,
        );
      }
    }
    return result;
  }

  static Future<void> _saveLocalEmotion(String date, EmotionType emotion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_emotion_$date', emotion.name);
  }

  static Future<List<String>> _getUnsyncedDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('unsynced_emotion_dates') ?? [];
  }

  static Future<void> _addUnsyncedDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList('unsynced_emotion_dates') ?? [];
    if (!dates.contains(date)) {
      dates.add(date);
      await prefs.setStringList('unsynced_emotion_dates', dates);
    }
  }

  static Future<void> _removeUnsyncedDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList('unsynced_emotion_dates') ?? [];
    if (dates.contains(date)) {
      dates.remove(date);
      await prefs.setStringList('unsynced_emotion_dates', dates);
    }
  }

  static Future<void> _syncUnsyncedEmotions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final unsynced = await _getUnsyncedDates();
    if (unsynced.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    for (var date in List<String>.from(unsynced)) {
      final emotionName = prefs.getString('local_emotion_$date');
      if (emotionName != null) {
        try {
          await _supabase.from('emotion_entries').upsert({
            'user_id': userId,
            'entry_date': date,
            'emotion': emotionName,
          }, onConflict: 'user_id, entry_date');
          
          await _removeUnsyncedDate(date);
        } catch (_) {
          break; // Break on network error, try again next time
        }
      }
    }
  }

  /// Get statistics for the month
  static Map<EmotionType, int> calculateMonthlyStats(Map<String, EmotionType> emotions) {
    final Map<EmotionType, int> stats = {};
    for (final type in EmotionType.values) {
      stats[type] = 0;
    }
    for (final emotion in emotions.values) {
      stats[emotion] = (stats[emotion] ?? 0) + 1;
    }
    return stats;
  }

  /// Get statistics for the last 7 days from a map of emotions
  static Map<EmotionType, int> calculateWeeklyStats(Map<String, EmotionType> emotions) {
    final Map<EmotionType, int> stats = {};
    for (final type in EmotionType.values) {
      stats[type] = 0;
    }

    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final emotion = emotions[dateStr];
      if (emotion != null) {
        stats[emotion] = (stats[emotion] ?? 0) + 1;
      }
    }
    return stats;
  }
}
