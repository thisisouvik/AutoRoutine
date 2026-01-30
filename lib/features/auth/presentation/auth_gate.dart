import 'package:autoroutine/features/auth/cubit/auth_cubit.dart';
import 'package:autoroutine/features/auth/cubit/auth_state.dart';
import 'package:autoroutine/features/auth/presentation/login_screen.dart';
import 'package:autoroutine/features/home/presentation/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return const MainNavigationScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
