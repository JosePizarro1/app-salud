import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryStorage {
  static final _supabase = Supabase.instance.client;

  /// Save or update a diary entry for a specific date (yyyy-MM-dd)
  static Future<void> saveDiaryEntry(String date, Map<String, String> fields) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('diary_entries').upsert({
      'user_id': userId,
      'entry_date': date,
      'porque': fields['porque'] ?? '',
      'meta': fields['meta'] ?? '',
      'prioridades': fields['prioridades'] ?? '',
      'logros': fields['logros'] ?? '',
    }, onConflict: 'user_id, entry_date');
  }

  /// Get all diary entries for a given month
  static Future<Map<String, Map<String, String>>> getDiaryForMonth(int year, int month) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final firstDay = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = '$year-${month.toString().padLeft(2, '0')}-${DateTime(year, month + 1, 0).day}';

    try {
      final List<dynamic> data = await _supabase
          .from('diary_entries')
          .select('entry_date, porque, meta, prioridades, logros')
          .eq('user_id', userId)
          .gte('entry_date', firstDay)
          .lte('entry_date', lastDay);

      final Map<String, Map<String, String>> result = {};
      for (var item in data) {
        final date = item['entry_date'] as String;
        result[date] = {
          'porque': item['porque'] as String? ?? '',
          'meta': item['meta'] as String? ?? '',
          'prioridades': item['prioridades'] as String? ?? '',
          'logros': item['logros'] as String? ?? '',
        };
      }
      return result;
    } catch (e) {
      // If table doesn't exist yet or other query error, return empty
      return {};
    }
  }
}
