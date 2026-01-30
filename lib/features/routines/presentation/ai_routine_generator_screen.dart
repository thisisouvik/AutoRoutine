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

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _AIRoutineGeneratorScreenState extends State<AIRoutineGeneratorScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentStep = 0;

  // Form data
  String _taskName = '';
  ScheduleFrequency _scheduleFrequency = ScheduleFrequency.daily;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  Set<DayOfWeek> _selectedDays = {};
  TaskType _taskType = TaskType.personal;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hey! 👋 I'm your routine assistant. Let's create an awesome routine together! What task would you like to schedule?",
    );
    _currentStep = 0;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      // Task name entered
      if (_inputController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a task name'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
        return;
      }
      _taskName = _inputController.text;
      _addUserMessage(_taskName);
      _addBotMessage(
        "Great! How often should '$_taskName' repeat? Choose: Daily, Specific days, or Custom frequency.",
      );
      _currentStep = 1;
      _inputController.clear();
    } else if (_currentStep == 3) {
      // Time selected
      _addBotMessage("Excellent! What category best describes this task?");
      _currentStep = 4;
    } else if (_currentStep == 4) {
      // Category selected
      _currentStep = 5;
      _showReviewAndSave();
    }
  }

  void _selectFrequency(ScheduleFrequency freq) {
    setState(() {
      _scheduleFrequency = freq;
    });
    _addUserMessage(freq.displayName);

    if (freq == ScheduleFrequency.specific_days) {
      _addBotMessage("Nice! Which days should '$_taskName' happen?");
      _currentStep = 2;
    } else {
      _addBotMessage("Perfect! What time works best for '$_taskName'?");
      _currentStep = 3;
    }
  }

  void _completeDaysSelection() {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
      return;
    }

    final daysText = _selectedDays.map((d) => d.shortName).join(', ');
    _addUserMessage(daysText);
    _addBotMessage("Great! What time works best for '$_taskName'?");
    _currentStep = 3;
  }

  void _showReviewAndSave() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Ready to Create?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReviewRow('Task:', _taskName),
              _buildReviewRow('Frequency:', _scheduleFrequency.displayName),
              if (_scheduleFrequency == ScheduleFrequency.specific_days &&
                  _selectedDays.isNotEmpty)
                _buildReviewRow(
                  'Days:',
                  _selectedDays.map((d) => d.shortName).join(', '),
                ),
              _buildReviewRow('Time:', _selectedTime.format(context)),
              _buildReviewRow('Category:', _taskType.displayName),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addBotMessage(
                'No problem! Let me know when you want to adjust anything.',
              );
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveRoutine();
            },
            child: const Text('Create Routine'),
          ),
        ],
      ),
    );
  }

  String _formatScheduleFrequency() {
    if (_scheduleFrequency == ScheduleFrequency.specific_days &&
        _selectedDays.isNotEmpty) {
      final days = _selectedDays.map((d) => d.shortName).join(', ');
      return 'Specific days ($days)';
    }

    if (_scheduleFrequency == ScheduleFrequency.custom_frequency &&
        _selectedDays.isNotEmpty) {
      final days = _selectedDays.map((d) => d.shortName).join(', ');
      return 'Custom frequency ($days)';
    }

    return _scheduleFrequency.displayName;
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _saveRoutine() async {
    try {
      _addBotMessage('Creating your routine... ⏳');

      await context.read<RoutineCubit>().addRoutine(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        message: _taskName,
        scheduleType: 'General',
        scheduleFrequency: _formatScheduleFrequency(),
      );

      dev.log('AI routine saved successfully', name: 'AIRoutineGenerator');

      _addBotMessage(
        'Awesome! 🎉 Your routine "$_taskName" has been created! Check your home screen to see it in action.',
      );

      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Routine created successfully!'),
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

      _addBotMessage('Oops! Something went wrong. Please try again. Error: $e');

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
      appBar: AppBar(
        title: const Text('AI Routine Assistant'),
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Colors.blue
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input section based on current step
          if (_currentStep == 0)
            _buildTaskInputSection()
          else if (_currentStep == 1)
            _buildFrequencySection()
          else if (_currentStep == 2)
            _buildDaysSection()
          else if (_currentStep == 3)
            _buildTimeSection()
          else if (_currentStep == 4)
            _buildCategorySection(),
        ],
      ),
    );
  }

  Widget _buildTaskInputSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Type your task...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _handleNextStep(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 'ai_send_fab',
            mini: true,
            onPressed: _handleNextStep,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...ScheduleFrequency.values.map((freq) {
            final isSelected = _scheduleFrequency == freq;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    _selectFrequency(freq);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(freq.displayName),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDaysSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                selectedColor: Colors.blue.shade200,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeDaysSelection,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
                _addUserMessage(_selectedTime.format(context));
                Future.delayed(const Duration(milliseconds: 300), () {
                  _handleNextStep();
                });
              }
            },
            child: Text(
              '🕐 ${_selectedTime.format(context)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TaskType.values.map((type) {
            final isSelected = _taskType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _taskType = type;
                  });
                  _addUserMessage(type.displayName);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _handleNextStep();
                  });
                },
                selectedColor: Colors.blue.shade200,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
