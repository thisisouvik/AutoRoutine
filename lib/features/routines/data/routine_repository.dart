import 'package:autoroutine/features/routines/data/routine_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Routine>> fetchRoutine() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('routine')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Routine>.from(
      (response as List).map((e) => Routine.fromMap(e as Map<String, dynamic>)),
    );
  }

  Future<void> addRoutine({
    required int hour,
    required int minute,
    required String message,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('routine').insert({
      'user_id': userId,
      'hour': hour,
      'min': minute,
      'message': message,
      'is_active': true,
    });
  }
}
