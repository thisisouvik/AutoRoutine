import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_suggest_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_suggest_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuggestRoutineScreen extends StatefulWidget {
  const SuggestRoutineScreen({super.key});

  @override
  State<SuggestRoutineScreen> createState() => _SuggestRoutineScreenState();
}

class _SuggestRoutineScreenState extends State<SuggestRoutineScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RoutineSuggestCubit>().loadSuggestions(days: 30, minFreq: 2);
  }

  void _addSuggestion(String taskName) {
    // Show dialog to confirm time
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Suggested Routine'),
        content: Text(
          'Add "$taskName" as a routine?\n\nSet time to default 9:00 AM.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RoutineCubit>().addRoutine(
                hour: 9,
                minute: 0,
                message: taskName,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Added: $taskName')));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Routines')),
      body: BlocBuilder<RoutineSuggestCubit, RoutineSuggestState>(
        builder: (context, state) {
          if (state is RoutineSuggestLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoutineSuggestLoaded) {
            if (state.suggestions.isEmpty) {
              return const Center(
                child: Text('No suggestions yet. Keep tracking activities!'),
              );
            }

            return ListView.builder(
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = state.suggestions[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(suggestion),
                    subtitle: const Text('Based on your activity'),
                    trailing: ElevatedButton(
                      onPressed: () => _addSuggestion(suggestion),
                      child: const Text('Add'),
                    ),
                  ),
                );
              },
            );
          }

          if (state is RoutineSuggestError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<RoutineSuggestCubit>().loadSuggestions(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
