import 'package:autoroutine/features/routines/domain/enums.dart';

/// Model for creating a new routine (form data)
class AddRoutineFormData {
  final String taskName;
  final ScheduleFrequency scheduleFrequency;
  final RoutineTimeOfDay selectedTime;
  final Set<DayOfWeek> selectedDays;
  final int customFrequencyDaysPerWeek;
  final TaskType taskType;
  final RoutineTemplate selectedTemplate;

  AddRoutineFormData({
    required this.taskName,
    required this.scheduleFrequency,
    required this.selectedTime,
    this.selectedDays = const {},
    this.customFrequencyDaysPerWeek = 1,
    required this.taskType,
    this.selectedTemplate = RoutineTemplate.none,
  });

  /// Validates if the form data is complete and valid
  ValidateResult validate() {
    // Check task name
    if (taskName.trim().isEmpty) {
      return ValidateResult(isValid: false, error: 'Please enter a task name');
    }

    // Check schedule-specific validations
    switch (scheduleFrequency) {
      case ScheduleFrequency.daily:
        // Daily doesn't need day selection
        break;
      case ScheduleFrequency.specific_days:
        if (selectedDays.isEmpty) {
          return ValidateResult(
            isValid: false,
            error: 'Please select at least one day',
          );
        }
        break;
      case ScheduleFrequency.custom_frequency:
        if (selectedDays.isEmpty) {
          return ValidateResult(
            isValid: false,
            error: 'Please select days for custom frequency',
          );
        }
        if (customFrequencyDaysPerWeek < 1 ||
            customFrequencyDaysPerWeek > selectedDays.length) {
          return ValidateResult(
            isValid: false,
            error:
                'Invalid frequency: must be between 1 and ${selectedDays.length}',
          );
        }
        break;
    }

    // Check template selection if task type is template
    if (taskType == TaskType.template &&
        selectedTemplate == RoutineTemplate.none) {
      return ValidateResult(
        isValid: false,
        error: 'Please select a template',
      );
    }

    return ValidateResult(isValid: true);
  }

  AddRoutineFormData copyWith({
    String? taskName,
    ScheduleFrequency? scheduleFrequency,
    RoutineTimeOfDay? selectedTime,
    Set<DayOfWeek>? selectedDays,
    int? customFrequencyDaysPerWeek,
    TaskType? taskType,
    RoutineTemplate? selectedTemplate,
  }) {
    return AddRoutineFormData(
      taskName: taskName ?? this.taskName,
      scheduleFrequency: scheduleFrequency ?? this.scheduleFrequency,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDays: selectedDays ?? this.selectedDays,
      customFrequencyDaysPerWeek:
          customFrequencyDaysPerWeek ?? this.customFrequencyDaysPerWeek,
      taskType: taskType ?? this.taskType,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    );
  }
}

/// TimeOfDay model for JSON serialization (avoiding Flutter's TimeOfDay)
class RoutineTimeOfDay {
  final int hour;
  final int minute;

  RoutineTimeOfDay({required this.hour, required this.minute});

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {'hour': hour, 'minute': minute};

  factory RoutineTimeOfDay.fromMap(Map<String, dynamic> map) =>
      RoutineTimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);

  factory RoutineTimeOfDay.now() {
    final now = DateTime.now();
    return RoutineTimeOfDay(hour: now.hour, minute: now.minute);
  }
}

/// Validation result
class ValidateResult {
  final bool isValid;
  final String? error;

  ValidateResult({required this.isValid, this.error});
}
