/// Schedule frequency types for routines
enum ScheduleFrequency { daily, specific_days, custom_frequency }

extension ScheduleFrequencyX on ScheduleFrequency {
  String get displayName {
    switch (this) {
      case ScheduleFrequency.daily:
        return 'Every day';
      case ScheduleFrequency.specific_days:
        return 'Specific days';
      case ScheduleFrequency.custom_frequency:
        return 'Custom frequency';
    }
  }
}

/// Task/Routine type after scheduling
enum TaskType { one_time, routine, template }

extension TaskTypeX on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.one_time:
        return 'One-time task (Today only)';
      case TaskType.routine:
        return 'Add to routine';
      case TaskType.template:
        return 'Add to routine template';
    }
  }
}

/// Predefined routine templates
enum RoutineTemplate { school, college, office, none }

extension RoutineTemplateX on RoutineTemplate {
  String get displayName {
    switch (this) {
      case RoutineTemplate.school:
        return 'School routine';
      case RoutineTemplate.college:
        return 'College routine';
      case RoutineTemplate.office:
        return 'Office routine';
      case RoutineTemplate.none:
        return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case RoutineTemplate.school:
        return 'For school students';
      case RoutineTemplate.college:
        return 'For college students';
      case RoutineTemplate.office:
        return 'For working professionals';
      case RoutineTemplate.none:
        return 'Create custom routine';
    }
  }
}

/// Days of the week enum
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension DayOfWeekX on DayOfWeek {
  String get shortName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
      case DayOfWeek.sunday:
        return 'Sun';
    }
  }

  String get fullName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  int get index {
    switch (this) {
      case DayOfWeek.monday:
        return 0;
      case DayOfWeek.tuesday:
        return 1;
      case DayOfWeek.wednesday:
        return 2;
      case DayOfWeek.thursday:
        return 3;
      case DayOfWeek.friday:
        return 4;
      case DayOfWeek.saturday:
        return 5;
      case DayOfWeek.sunday:
        return 6;
    }
  }
}
