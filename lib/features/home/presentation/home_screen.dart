import 'package:autoroutine/features/auth/cubit/auth_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_state.dart';
import 'package:autoroutine/features/routines/data/routine_model.dart';
import 'package:autoroutine/features/routines/presentation/add_routine_screen.dart';
import 'package:autoroutine/features/routines/presentation/ai_routine_generator_screen.dart';
import 'package:autoroutine/features/routines/presentation/suggest_routine_screen.dart';
import 'package:autoroutine/features/routines/presentation/template_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedScheduleType = 'All';
  final List<String> _scheduleTypes = [
    'All',
    'General',
    'Home',
    'College',
    'Office',
    'Gym',
  ];

  @override
  void initState() {
    super.initState();
    // Load all routines by default
    context.read<RoutineCubit>().loadRoutines();
  }

  void _onScheduleTypeChanged(String? newType) {
    if (newType != null) {
      setState(() {
        _selectedScheduleType = newType;
      });
      // Load all routines or filter by specific type
      if (newType == 'All') {
        context.read<RoutineCubit>().loadRoutines();
      } else {
        context.read<RoutineCubit>().loadRoutinesByType(newType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoRoutine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Generator',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AIRoutineGeneratorScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            tooltip: 'Templates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TemplateListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Suggestions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SuggestRoutineScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Schedule Type Filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Schedule Type:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedScheduleType.isEmpty
                        ? null
                        : _selectedScheduleType,
                    items: _scheduleTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: _onScheduleTypeChanged,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<RoutineCubit, RoutineState>(
              builder: (context, state) {
                if (state is RoutineLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RoutineLoaded) {
                  if (state.routines.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedScheduleType == 'All'
                                ? 'No routines yet'
                                : 'No routines for $_selectedScheduleType',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap + to add your first routine',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.routines.length,
                    itemBuilder: (context, index) {
                      final routine = state.routines[index];
                      return _RoutineCard(
                        routine: routine,
                        onComplete: () {
                          context.read<RoutineCubit>().toggleRoutineCompletion(
                            routine.id,
                            !routine.isCompleted,
                          );
                        },
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
          ),
        ],
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

/// Custom routine card widget with new design
class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onComplete;

  const _RoutineCard({required this.routine, required this.onComplete});

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: routine.isCompleted
            ? BorderSide(color: Colors.green.shade300, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template name (if part of a template)
            if (routine.templateName != null &&
                routine.templateName!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  routine.templateName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (routine.templateName != null &&
                routine.templateName!.isNotEmpty)
              const SizedBox(height: 8),

            // Task name (bold)
            Text(
              routine.message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: routine.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: routine.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Schedule frequency and time row
            Row(
              children: [
                // Frequency (semi-bold)
                Expanded(
                  child: Text(
                    routine.scheduleFrequency,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                // Time (right side)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(routine.hour, routine.minute),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Completion button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: routine.isCompleted
                      ? Colors.grey.shade300
                      : Colors.green,
                  foregroundColor: routine.isCompleted
                      ? Colors.grey.shade700
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  routine.isCompleted ? Icons.undo : Icons.check_circle_outline,
                ),
                label: Text(
                  routine.isCompleted
                      ? 'Mark as Incomplete'
                      : 'Mark as Complete',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
