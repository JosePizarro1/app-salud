import 'package:supabase_flutter/supabase_flutter.dart';

class TaskStorage {
  static final _supabase = Supabase.instance.client;

  /// Get all tasks for a given month
  static Future<Map<String, List<Map<String, dynamic>>>> getTasksForMonth(int year, int month) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final firstDay = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = '$year-${month.toString().padLeft(2, '0')}-${DateTime(year, month + 1, 0).day}';

    try {
      final List<dynamic> data = await _supabase
          .from('daily_tasks')
          .select('id, entry_date, title, is_done, position')
          .eq('user_id', userId)
          .gte('entry_date', firstDay)
          .lte('entry_date', lastDay)
          .order('position', ascending: true);

      final Map<String, List<Map<String, dynamic>>> result = {};
      for (var item in data) {
        final date = item['entry_date'] as String;
        if (!result.containsKey(date)) {
          result[date] = [];
        }
        result[date]!.add({
          'id': item['id'] as int,
          'title': item['title'] as String,
          'done': item['is_done'] as bool? ?? false,
        });
      }
      return result;
    } catch (e) {
      // If table doesn't exist yet or query error, return empty
      return {};
    }
  }

  /// Add a new task for a specific date
  static Future<int?> addTask(String date, String title, int position) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase.from('daily_tasks').insert({
        'user_id': userId,
        'entry_date': date,
        'title': title,
        'is_done': false,
        'position': position,
      }).select('id').single();

      return response['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Toggle task state
  static Future<void> toggleTask(int taskId, bool isDone) async {
    try {
      await _supabase.from('daily_tasks').update({
        'is_done': isDone,
      }).eq('id', taskId);
    } catch (e) {
      // Ignore or log error
    }
  }

  /// Delete a task
  static Future<void> deleteTask(int taskId) async {
    try {
      await _supabase.from('daily_tasks').delete().eq('id', taskId);
    } catch (e) {
      // Ignore or log error
    }
  }
}
