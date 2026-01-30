import 'package:autoroutine/features/routines/data/routine_model.dart';
import 'package:autoroutine/features/routines/data/template_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Routine>> fetchRoutine() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Fetch user's routines
    final response = await _client
        .from('routine')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final routines = List<Routine>.from(
      (response as List).map((e) => Routine.fromMap(e as Map<String, dynamic>)),
    );

    // Fetch active templates and their routines
    final templates = await _client
        .from('routine_template')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true);

    // Convert template routines to regular routines for display
    for (var template in templates) {
      final templateId = template['id'] as String;
      final templateRoutines = await _client
          .from('template_routine')
          .select()
          .eq('template_id', templateId);

      // Add template routines to the list
      for (var routine in templateRoutines) {
        routines.add(
          Routine(
            id: '${templateId}_${routine['id']}',
            hour: routine['hour'] as int,
            minute: routine['min'] as int,
            message: routine['message'] as String,
            isActive: routine['is_active'] as bool? ?? true,
            scheduleType: template['schedule_type'] as String? ?? 'Template',
            scheduleFrequency: 'Template',
            templateName: template['name'] as String?,
            isCompleted: false,
            taskType: 'template',
          ),
        );
      }
    }

    return routines;
  }

  Future<List<Routine>> fetchRoutinesByType(String scheduleType) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('routine')
        .select()
        .eq('user_id', userId)
        .eq('schedule_type', scheduleType)
        .order('created_at', ascending: false);

    return List<Routine>.from(
      (response as List).map((e) => Routine.fromMap(e as Map<String, dynamic>)),
    );
  }

  Future<void> addRoutine({
    required int hour,
    required int minute,
    required String message,
    String scheduleType = 'General',
    String scheduleFrequency = 'Every day',
    String? templateName,
    String taskType = 'routine',
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('routine').insert({
      'user_id': userId,
      'hour': hour,
      'min': minute,
      'message': message,
      'is_active': true,
      'schedule_type': scheduleType,
      'schedule_frequency': scheduleFrequency,
      'template_name': templateName,
      'task_type': taskType,
      'is_completed': false,
    });
  }

  Future<void> toggleRoutineCompletion(
    String routineId,
    bool isCompleted,
  ) async {
    await _client
        .from('routine')
        .update({'is_completed': isCompleted})
        .eq('id', routineId);
  }
}
