import 'package:autoroutine/features/routines/data/routine_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Iterable<Routine>> fetchRoutine() async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('routine')
        .select()
        .eq('user_id', userId)
        .order('created at', ascending: false);

    return (response as List).map((e) => Routine.fromMap(e));
  }

  Future<void> addRoutine({
    required int hour,
    required int minute,
    required String message,
  }) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('routine').insert({
      'user_id' : userId,
      'hour' : hour,
      'minute' : minute,
      'message' : message,
    });
  }
}
