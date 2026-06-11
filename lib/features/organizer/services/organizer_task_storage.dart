import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizerTaskStorage {
  static final _supabase = Supabase.instance.client;

  /// Retrieves tasks for a given month to display indicators in the calendar
  static Future<Map<String, List<Map<String, dynamic>>>> getTasksForMonth(int year, int month) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final firstDay = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = '$year-${month.toString().padLeft(2, '0')}-${DateTime(year, month + 1, 0).day}';

    try {
      final List<dynamic> data = await _supabase
          .from('organizer_tasks')
          .select('id, entry_date, title, is_completed, dimension, task_time')
          .eq('user_id', userId)
          .gte('entry_date', firstDay)
          .lte('entry_date', lastDay);

      final Map<String, List<Map<String, dynamic>>> result = {};
      for (var item in data) {
        final date = item['entry_date'] as String;
        if (!result.containsKey(date)) {
          result[date] = [];
        }
        result[date]!.add({
          'id': item['id'] as int,
          'title': item['title'] as String,
          'is_completed': item['is_completed'] as bool? ?? false,
          'dimension': item['dimension'] as int,
          'task_time': item['task_time'] as String,
        });
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  /// Retrieves tasks for a specific date, sorted by Eisenhower dimension (1 to 4)
  static Future<List<Map<String, dynamic>>> getTasksForDate(String dateStr) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final List<dynamic> data = await _supabase
          .from('organizer_tasks')
          .select('id, entry_date, title, task_time, dimension, notes, is_completed')
          .eq('user_id', userId)
          .eq('entry_date', dateStr)
          .order('dimension', ascending: true)
          .order('task_time', ascending: true);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  /// Adds a new task to the database
  static Future<int?> addTask({
    required String dateStr,
    required String title,
    required String timeStr,
    required int dimension,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase.from('organizer_tasks').insert({
        'user_id': userId,
        'entry_date': dateStr,
        'title': title,
        'task_time': timeStr,
        'dimension': dimension,
        'notes': notes ?? '',
        'is_completed': false,
      }).select('id').single();

      return response['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Toggles task completion. Returns true if points were newly awarded (+5 points).
  static Future<bool> toggleTask(int taskId, String dateStr, bool isCompleted) async {
    try {
      await _supabase
          .from('organizer_tasks')
          .update({'is_completed': isCompleted})
          .eq('id', taskId);

      // If the task was completed, we try to award points for today's use
      if (isCompleted) {
        return await checkAndAwardDailyPoints(dateStr);
      }
    } catch (e) {
      // ignore
    }
    return false;
  }

  /// Deletes a task
  static Future<void> deleteTask(int taskId) async {
    try {
      await _supabase.from('organizer_tasks').delete().eq('id', taskId);
    } catch (e) {
      // ignore
    }
  }

  /// Safely attempts to log +5 points for completing a task on a given date.
  /// Handled via DB unique constraint to guarantee points are rewarded only once a day.
  static Future<bool> checkAndAwardDailyPoints(String dateStr) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('user_points_history').insert({
        'user_id': userId,
        'earned_date': dateStr,
        'points': 5,
        'reason': 'task_completion',
      });
      return true;
    } catch (e) {
      // Duplicate key error occurs if they already completed a task on this date
      return false;
    }
  }
}
