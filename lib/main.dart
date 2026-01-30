import 'dart:developer' as dev;
import 'package:autoroutine/core/presentation/splash_screen.dart';
import 'package:autoroutine/features/auth/cubit/auth_cubit.dart';
import 'package:autoroutine/features/auth/presentation/auth_gate.dart';
import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_suggest_cubit.dart';
import 'package:autoroutine/features/routines/cubit/template_cubit.dart';
import 'package:autoroutine/features/routines/data/activity_repository.dart';
import 'package:autoroutine/features/routines/data/routine_repository.dart';
import 'package:autoroutine/features/routines/data/template_repository.dart';
import 'package:autoroutine/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    dev.log('Warning: .env file not found: $e');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase credentials are missing. Check .env for SUPABASE_URL and SUPABASE_ANON_KEY',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => RoutineCubit(RoutineRepository())),
        BlocProvider(create: (_) => TemplateCubit(TemplateRepository())),
        BlocProvider(create: (_) => RoutineSuggestCubit(ActivityRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/auth': (context) => AuthGate(),
        },
      ),
    );
  }
}
