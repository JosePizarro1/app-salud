import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/emotion_entry.dart';

class EmotionStorage {
  static final _supabase = Supabase.instance.client;

  /// Save or update an emotion for a specific date (yyyy-MM-dd)
  static Future<void> saveEmotion(String date, EmotionType emotion) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('emotion_entries').upsert({
      'user_id': userId,
      'entry_date': date,
      'emotion': emotion.name,
    }, onConflict: 'user_id, entry_date');
  }

  /// Get all emotions for a given month
  static Future<Map<String, EmotionType>> getEmotionsForMonth(int year, int month) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final firstDay = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = '$year-${month.toString().padLeft(2, '0')}-${DateTime(year, month + 1, 0).day}';

    final List<dynamic> data = await _supabase
        .from('emotion_entries')
        .select('entry_date, emotion')
        .eq('user_id', userId)
        .gte('entry_date', firstDay)
        .lte('entry_date', lastDay);

    final Map<String, EmotionType> result = {};
    for (var item in data) {
      final date = item['entry_date'] as String;
      final emotionName = item['emotion'] as String;
      result[date] = EmotionType.values.firstWhere(
        (e) => e.name == emotionName,
        orElse: () => EmotionType.happy,
      );
    }
    return result;
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
