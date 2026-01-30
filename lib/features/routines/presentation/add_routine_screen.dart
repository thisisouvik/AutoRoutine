import 'dart:developer' as dev;

import 'package:autoroutine/features/routines/cubit/add_routine_cubit.dart';
import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:autoroutine/features/routines/cubit/template_cubit.dart';
import 'package:autoroutine/features/routines/cubit/template_state.dart';
import 'package:autoroutine/features/routines/data/template_model.dart';
import 'package:autoroutine/features/routines/domain/add_routine_model.dart';
import 'package:autoroutine/features/routines/domain/enums.dart';
import 'package:autoroutine/features/routines/presentation/widgets/add_routine_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatScheduleFrequency(AddRoutineFormData formData) {
    if (formData.scheduleFrequency == ScheduleFrequency.specific_days &&
        formData.selectedDays.isNotEmpty) {
      final days = formData.selectedDays.map((d) => d.shortName).join(', ');
      return 'Specific days ($days)';
    }

    if (formData.scheduleFrequency == ScheduleFrequency.custom_frequency &&
        formData.selectedDays.isNotEmpty) {
      final days = formData.selectedDays.map((d) => d.shortName).join(', ');
      return 'Custom frequency ($days)';
    }

    return formData.scheduleFrequency.displayName;
  }

  Future<void> _saveRoutine(
    BuildContext context,
    AddRoutineFormData formData,
  ) async {
    // Save routine with all details
    try {
      await context.read<RoutineCubit>().addRoutine(
        hour: formData.selectedTime.hour,
        minute: formData.selectedTime.minute,
        message: formData.taskName,
        scheduleType: formData.selectedTemplateId ?? 'General',
        scheduleFrequency: _formatScheduleFrequency(formData),
        templateName: formData.selectedTemplateId,
      );

      dev.log('Routine saved successfully', name: 'AddRoutineScreen');

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Your routine has been saved!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );

      // Reload routines and navigate to home screen
      await context.read<RoutineCubit>().loadRoutines();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e, st) {
      dev.log(
        'Failed to save routine: $e',
        name: 'AddRoutineScreen',
        stackTrace: st,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AddRoutineCubit())],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Add Routine'), elevation: 0),
          body: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                minHeight: 4,
              ),
              // Step content
              Expanded(
                child: BlocBuilder<AddRoutineCubit, AddRoutineState>(
                  builder: (context, state) {
                    if (state is! AddRoutineInitial) {
                      return const SizedBox.shrink();
                    }

                    return PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentStep = index);
                      },
                      children: [
                        // Step 1: Task Name
                        _buildTaskNameStep(context, state.formData),
                        // Step 2: Schedule Frequency
                        _buildScheduleFrequencyStep(context, state.formData),
                        // Step 3: Time & Days
                        _buildTimeAndDaysStep(context, state.formData),
                        // Step 4: Task Type
                        _buildTaskTypeStep(context, state.formData),
                        // Step 5: Template Selection (if needed)
                        _buildTemplateStep(context, state.formData),
                      ],
                    );
                  },
                ),
              ),
              // Navigation buttons
              BlocListener<AddRoutineCubit, AddRoutineState>(
                listener: (context, state) {
                  if (state is AddRoutineError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(
                          bottom: 80,
                          left: 16,
                          right: 16,
                        ),
                      ),
                    );
                  } else if (state is AddRoutineValid) {
                    _saveRoutine(context, state.formData);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentStep > 0 ? _previousStep : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                      if (_currentStep < 4)
                        ElevatedButton.icon(
                          onPressed: _nextStep,
                          label: const Text('Next'),
                          icon: const Icon(Icons.arrow_forward),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<AddRoutineCubit>()
                                .validateAndProceed();
                          },
                          label: const Text('Save Routine'),
                          icon: const Icon(Icons.check),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1: Task Name Input
  Widget _buildTaskNameStep(BuildContext context, AddRoutineFormData formData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          StepCard(
            title: 'Step 1 of 5',
            subtitle: 'What do you want to add?',
            child: TextField(
              onChanged: (value) {
                context.read<AddRoutineCubit>().updateTaskName(value);
              },
              decoration: InputDecoration(
                hintText: 'e.g., Gym, Study, Meditate, Drink Water',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.task),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: Schedule Frequency
  Widget _buildScheduleFrequencyStep(
    BuildContext context,
    AddRoutineFormData formData,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const StepCard(
            title: 'Step 2 of 5',
            subtitle: 'How often do you want to do this?',
            child: SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          OptionCard<ScheduleFrequency>(
            value: ScheduleFrequency.daily,
            groupValue: formData.scheduleFrequency,
            title: 'Every day',
            subtitle: 'Repeats daily at the same time',
            onChanged: (frequency) {
              context.read<AddRoutineCubit>().updateScheduleFrequency(
                frequency,
              );
            },
          ),
          const SizedBox(height: 12),
          OptionCard<ScheduleFrequency>(
            value: ScheduleFrequency.specific_days,
            groupValue: formData.scheduleFrequency,
            title: 'Specific days of the week',
            subtitle: 'e.g., Monday & Thursday',
            onChanged: (frequency) {
              context.read<AddRoutineCubit>().updateScheduleFrequency(
                frequency,
              );
            },
          ),
          const SizedBox(height: 12),
          OptionCard<ScheduleFrequency>(
            value: ScheduleFrequency.custom_frequency,
            groupValue: formData.scheduleFrequency,
            title: 'Custom frequency',
            subtitle: 'e.g., 2-3 days per week',
            onChanged: (frequency) {
              context.read<AddRoutineCubit>().updateScheduleFrequency(
                frequency,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Step 3: Time & Days Selection
  Widget _buildTimeAndDaysStep(
    BuildContext context,
    AddRoutineFormData formData,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          StepCard(
            title: 'Step 3 of 5',
            subtitle: 'When and which days?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Picker
                const Text(
                  'Select Time:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TimePickerButton(
                  selectedTime: formData.selectedTime,
                  onPressed: () async {
                    final flutterTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: formData.selectedTime.hour,
                        minute: formData.selectedTime.minute,
                      ),
                    );
                    if (flutterTime != null) {
                      context.read<AddRoutineCubit>().updateTime(
                        RoutineTimeOfDay(
                          hour: flutterTime.hour,
                          minute: flutterTime.minute,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Days Selector (if not daily)
                if (formData.scheduleFrequency != ScheduleFrequency.daily) ...[
                  const Text(
                    'Select Days:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  DaySelector(
                    selectedDays: formData.selectedDays,
                    onDayToggled: (day) {
                      context.read<AddRoutineCubit>().toggleDay(day);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Custom Frequency Slider (if custom)
                  if (formData.scheduleFrequency ==
                      ScheduleFrequency.custom_frequency) ...[
                    const Text(
                      'Days per Week:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: formData.customFrequencyDaysPerWeek.toDouble(),
                      min: 1,
                      max: formData.selectedDays.isEmpty
                          ? 7
                          : formData.selectedDays.length.toDouble(),
                      divisions: formData.selectedDays.isEmpty
                          ? 6
                          : formData.selectedDays.length - 1,
                      label: '${formData.customFrequencyDaysPerWeek} days',
                      onChanged: (value) {
                        context.read<AddRoutineCubit>().updateCustomFrequency(
                          value.toInt(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
                // Frequency Info
                FrequencyInfo(
                  frequency: formData.scheduleFrequency,
                  selectedDays: formData.selectedDays,
                  customFrequencyDaysPerWeek:
                      formData.customFrequencyDaysPerWeek,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 4: Task Type Selection
  Widget _buildTaskTypeStep(BuildContext context, AddRoutineFormData formData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const StepCard(
            title: 'Step 4 of 5',
            subtitle: 'How do you want to save this?',
            child: SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          OptionCard<TaskType>(
            value: TaskType.one_time,
            groupValue: formData.taskType,
            title: TaskType.one_time.displayName,
            subtitle: 'Acts like a normal to-do for today',
            onChanged: (type) {
              context.read<AddRoutineCubit>().updateTaskType(type);
            },
          ),
          const SizedBox(height: 12),
          OptionCard<TaskType>(
            value: TaskType.routine,
            groupValue: formData.taskType,
            title: TaskType.routine.displayName,
            subtitle: 'Set up a recurring schedule',
            onChanged: (type) {
              context.read<AddRoutineCubit>().updateTaskType(type);
            },
          ),
          const SizedBox(height: 12),
          OptionCard<TaskType>(
            value: TaskType.template,
            groupValue: formData.taskType,
            title: TaskType.template.displayName,
            subtitle: 'Save as a reusable template',
            onChanged: (type) {
              context.read<AddRoutineCubit>().updateTaskType(type);
            },
          ),
        ],
      ),
    );
  }

  /// Step 5: Template Selection (if TaskType.template is selected)
  Widget _buildTemplateStep(BuildContext context, AddRoutineFormData formData) {
    if (formData.taskType != TaskType.template) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const StepCard(
              title: 'Step 5 of 5',
              subtitle: 'Review your routine',
              child: Text('Your routine is ready to save!'),
            ),
          ],
        ),
      );
    }

    // Use BlocBuilder to display user-created templates
    return BlocBuilder<TemplateCubit, TemplateState>(
      builder: (context, templateState) {
        final List<RoutineTemplate> templates = templateState is TemplateLoaded
            ? templateState.templates
            : [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const StepCard(
                title: 'Step 5 of 5',
                subtitle: 'Which template?',
                child: SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              if (templates.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.folder_open,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No templates yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first template to organize routines',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/create-template');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Template'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...templates.map(
                  (template) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OptionCard<String>(
                      value: template.id,
                      groupValue: formData.selectedTemplateId ?? '',
                      title: template.name,
                      subtitle: template.description ?? 'No description',
                      onChanged: (id) {
                        context.read<AddRoutineCubit>().updateTemplateId(id);
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
