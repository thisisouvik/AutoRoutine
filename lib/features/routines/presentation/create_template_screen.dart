import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_state.dart';
import 'package:autoroutine/features/routines/cubit/template_cubit.dart';
import 'package:autoroutine/features/routines/data/template_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<int> _selectedRoutineIndices = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTemplate(List<dynamic> routines) {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter template name')),
      );
      return;
    }

    if (_selectedRoutineIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one routine')),
      );
      return;
    }

    // Convert selected routines to TemplateRoutine objects
    final selectedRoutines = _selectedRoutineIndices
        .map((i) => routines[i])
        .cast<dynamic>()
        .map((r) {
          return TemplateRoutine(
            hour: r.hour,
            min: r.minute,
            message: r.message,
            isActive: r.isActive,
          );
        })
        .toList();

    context.read<TemplateCubit>().createTemplate(
      name: name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      scheduleType: name, // Use template name as schedule type
      routines: selectedRoutines,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Template "$name" created!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Template')),
      body: BlocBuilder<RoutineCubit, RoutineState>(
        builder: (context, state) {
          if (state is RoutineLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoutineLoaded) {
            final routines = state.routines;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'e.g., Hostel Schedule, Home Schedule',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g., My weekday morning routine for the hostel',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Routines to Include',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (routines.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No routines available. Create routines first.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Column(
                    children: List.generate(routines.length, (index) {
                      final routine = routines[index];
                      final isSelected = _selectedRoutineIndices.contains(
                        index,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedRoutineIndices.add(index);
                              } else {
                                _selectedRoutineIndices.remove(index);
                              }
                            });
                          },
                          title: Text(routine.message),
                          subtitle: Text(
                            '${routine.hour.toString().padLeft(2, '0')}:${routine.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: routines.isEmpty
                        ? null
                        : () => _saveTemplate(routines),
                    child: const Text('Create Template'),
                  ),
                ),
              ],
            );
          }

          if (state is RoutineError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Unable to load routines'));
        },
      ),
    );
  }
}
