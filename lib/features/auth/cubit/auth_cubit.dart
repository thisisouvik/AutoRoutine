import 'auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _checkSession();
  }

  final SupabaseClient _client = Supabase.instance.client;

  void _checkSession() {
    final session = _client.auth.currentSession;
    if (session != null) {
      emit(AuthAuthenticated((session.user.id)));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(response.user!.id));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'name': name,
      });

      emit(AuthAuthenticated(response.user!.id));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    emit(AuthUnauthenticated());
  }
}
