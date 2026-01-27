import 'package:autoroutine/features/routines/data/template_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TemplateRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<RoutineTemplate>> fetchTemplates() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final templates = await _client
        .from('routine_template')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    List<RoutineTemplate> result = [];
    for (var template in templates) {
      final t = RoutineTemplate.fromMap(template);

      // Fetch routines for this template
      final routines = await _client
          .from('template_routine')
          .select()
          .eq('template_id', t.id);

      t.routines.addAll(
        (routines as List)
            .map((e) => TemplateRoutine.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

      result.add(t);
    }

    return result;
  }

  Future<String> createTemplate({
    required String name,
    String? description,
    required List<TemplateRoutine> routines,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Insert template
    final templateResponse = await _client.from('routine_template').insert({
      'user_id': userId,
      'name': name,
      'description': description,
    }).select();

    final templateId = templateResponse[0]['id'] as String;

    // Insert routines for template
    if (routines.isNotEmpty) {
      await _client
          .from('template_routine')
          .insert(
            routines
                .map((r) => {...r.toMap(), 'template_id': templateId})
                .toList(),
          );
    }

    return templateId;
  }

  Future<void> deleteTemplate(String templateId) async {
    await _client.from('routine_template').delete().eq('id', templateId);
  }

  Future<void> applyTemplate(String templateId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Fetch template routines
    final routines = await _client
        .from('template_routine')
        .select()
        .eq('template_id', templateId);

    // Insert each routine into user's routine table
    for (var routine in routines) {
      await _client.from('routine').insert({
        'user_id': userId,
        'hour': routine['hour'],
        'min': routine['min'],
        'message': routine['message'],
        'is_active': routine['is_active'] ?? true,
      });
    }
  }
}
