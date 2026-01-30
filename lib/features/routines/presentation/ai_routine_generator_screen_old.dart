import 'dart:developer' as dev;
import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:autoroutine/features/routines/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AIRoutineGeneratorScreen extends StatefulWidget {
  const AIRoutineGeneratorScreen({super.key});

  @override
  State<AIRoutineGeneratorScreen> createState() =>
      _AIRoutineGeneratorScreenState();
}

class _AIRoutineGeneratorScreenState extends State<AIRoutineGeneratorScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  // Form data
  String _taskName = '';
  ScheduleFrequency _scheduleFrequency = ScheduleFrequency.daily;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  Set<DayOfWeek> _selectedDays = {};
  TaskType _taskType = TaskType.personal;

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _taskNameController.dispose();
    _responseController.dispose();
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

  Future<void> _saveRoutine() async {
    try {
      await context.read<RoutineCubit>().addRoutine(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        message: _taskName,
        scheduleType: 'General',
        scheduleFrequency: _scheduleFrequency.displayName,
      );

      dev.log('AI routine saved successfully', name: 'AIRoutineGenerator');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Your AI routine has been created!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
          duration: Duration(seconds: 2),
        ),
      );

      await context.read<RoutineCubit>().loadRoutines();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e, st) {
      dev.log(
        'Failed to save AI routine: $e',
        name: 'AIRoutineGenerator',
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
    return Scaffold(
      appBar: AppBar(title: const Text('AI Schedule Generator'), elevation: 0),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(value: (_currentStep + 1) / 5, minHeight: 4),
          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildTaskNameStep(),
                _buildScheduleFrequencyStep(),
                _buildTimeAndDaysStep(),
                _buildTaskTypeStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          // Navigation buttons
          Padding(
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
                    onPressed: _saveRoutine,
                    label: const Text('Create Routine'),
                    icon: const Icon(Icons.check),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            "Hey! Let's create your routine 👋",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "What task would you like to schedule?",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _taskNameController,
            onChanged: (value) {
              setState(() {
                _taskName = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Type your task here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.edit),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          _buildExampleChips([
            'Morning workout',
            'Study session',
            'Team meeting',
            'Meditation',
          ]),
        ],
      ),
    );
  }

  Widget _buildScheduleFrequencyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.repeat, size: 48, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            "How often?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "When should '$_taskName' repeat?",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ...ScheduleFrequency.values.map((freq) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: _scheduleFrequency == freq
                  ? Colors.blue.withOpacity(0.1)
                  : null,
              child: ListTile(
                leading: Icon(
                  _getFrequencyIcon(freq),
                  color: _scheduleFrequency == freq ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  freq.displayName,
                  style: TextStyle(
                    fontWeight: _scheduleFrequency == freq
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _scheduleFrequency == freq
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    _scheduleFrequency = freq;
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeAndDaysStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, size: 48, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            "What time?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Pick the best time for this task",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Time'),
              trailing: Text(
                _selectedTime.format(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
          ),
          if (_scheduleFrequency == ScheduleFrequency.specific_days) ...[
            const SizedBox(height: 32),
            const Text(
              "Which days?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DayOfWeek.values.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(day.shortName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.category_outlined, size: 48, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            "What category?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Help us organize your routine better",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ...TaskType.values.map((type) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: _taskType == type ? Colors.blue.withOpacity(0.1) : null,
              child: ListTile(
                leading: Icon(
                  _getTaskTypeIcon(type),
                  color: _taskType == type ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  type.displayName,
                  style: TextStyle(
                    fontWeight: _taskType == type
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _taskType == type
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    _taskType = type;
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            "Looks good?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Review your routine before creating",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewItem(Icons.task_alt, 'Task', _taskName),
                  const Divider(),
                  _buildReviewItem(
                    Icons.repeat,
                    'Frequency',
                    _scheduleFrequency.displayName,
                  ),
                  const Divider(),
                  _buildReviewItem(
                    Icons.access_time,
                    'Time',
                    _selectedTime.format(context),
                  ),
                  if (_scheduleFrequency == ScheduleFrequency.specific_days &&
                      _selectedDays.isNotEmpty) ...[
                    const Divider(),
                    _buildReviewItem(
                      Icons.calendar_today,
                      'Days',
                      _selectedDays.map((d) => d.shortName).join(', '),
                    ),
                  ],
                  const Divider(),
                  _buildReviewItem(
                    Icons.category,
                    'Category',
                    _taskType.displayName,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChips(List<String> examples) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: examples.map((example) {
        return ActionChip(
          label: Text(example),
          onPressed: () {
            _taskNameController.text = example;
            setState(() {
              _taskName = example;
            });
          },
          avatar: const Icon(Icons.lightbulb_outline, size: 16),
        );
      }).toList(),
    );
  }

  IconData _getFrequencyIcon(ScheduleFrequency freq) {
    switch (freq) {
      case ScheduleFrequency.daily:
        return Icons.today;
      case ScheduleFrequency.specific_days:
        return Icons.calendar_view_week;
      case ScheduleFrequency.custom_frequency:
        return Icons.tune;
    }
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.personal:
        return Icons.person;
      case TaskType.one_time:
        return Icons.schedule;
      case TaskType.routine:
        return Icons.repeat;
      case TaskType.template:
        return Icons.calendar_view_week;
    }
  }
}
