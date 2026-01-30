import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> logActivity({
    required String taskName,
    String? routineId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('activity_log').insert({
      'user_id': userId,
      'task_name': taskName,
      'routine_id': routineId,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getActivityHistory({int days = 30}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('activity_log')
        .select()
        .eq('user_id', userId)
        .gt(
          'completed_at',
          DateTime.now().subtract(Duration(days: days)).toIso8601String(),
        )
        .order('completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, int>> analyzeFrequency({int days = 30}) async {
    final history = await getActivityHistory(days: days);
    Map<String, int> frequency = {};

    for (var log in history) {
      String taskName = log['task_name'] as String;
      frequency[taskName] = (frequency[taskName] ?? 0) + 1;
    }

    return frequency;
  }

  Future<List<String>> getSuggestedRoutines({
    int days = 30,
    int minFrequency = 2,
  }) async {
    final frequency = await analyzeFrequency(days: days);

    // Suggest tasks done at least minFrequency times in the period
    return frequency.entries
        .where((e) => e.value >= minFrequency)
        .map((e) => e.key)
        .toList();
  }
}
