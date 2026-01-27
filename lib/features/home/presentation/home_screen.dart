import 'package:autoroutine/features/auth/cubit/auth_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_state.dart';
import 'package:autoroutine/features/routines/presentation/add_routine_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RoutineCubit>().loadRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoRoutine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: BlocBuilder<RoutineCubit, RoutineState>(
        builder: (context, state) {
          if (state is RoutineLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoutineLoaded) {
            if (state.routines.isEmpty) {
              return const Center(child: Text('No routines yet'));
            }

            return ListView.builder(
              itemCount: state.routines.length,
              itemBuilder: (context, index) {
                final routine = state.routines[index];
                return ListTile(
                  title: Text(routine.message),
                  subtitle: Text(
                    '${routine.hour.toString().padLeft(2, '0')}:${routine.minute.toString().padLeft(2, '0')}',
                  ),
                );
              },
            );
          }

          if (state is RoutineError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<RoutineCubit>().loadRoutines(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRoutineScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
