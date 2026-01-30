class Routine {
  final String id;
  final int hour;
  final int minute;
  final String message;
  final bool isActive;
  final String scheduleType;
  final String scheduleFrequency;
  final String? templateName;
  final bool isCompleted;
  final String taskType; // 'one_time', 'routine', 'template', 'personal'

  Routine({
    required this.id,
    required this.hour,
    required this.minute,
    required this.message,
    required this.isActive,
    this.scheduleType = 'General',
    this.scheduleFrequency = 'Every day',
    this.templateName,
    this.isCompleted = false,
    this.taskType = 'routine',
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'] as String,
      hour: (map['hour'] ?? map['hr']) as int,
      minute: (map['minute'] ?? map['min']) as int,
      message: map['message'] as String,
      isActive: (map['is_active'] ?? map['isActive'] ?? false) as bool,
      scheduleType: map['schedule_type'] as String? ?? 'General',
      scheduleFrequency: map['schedule_frequency'] as String? ?? 'Every day',
      templateName: map['template_name'] as String?,
      isCompleted: (map['is_completed'] ?? false) as bool,
      taskType: map['task_type'] as String? ?? 'routine',
    );
  }

  Routine copyWith({
    String? id,
    int? hour,
    int? minute,
    String? message,
    bool? isActive,
    String? scheduleType,
    String? scheduleFrequency,
    String? templateName,
    bool? isCompleted,
    String? taskType,
  }) {
    return Routine(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleFrequency: scheduleFrequency ?? this.scheduleFrequency,
      templateName: templateName ?? this.templateName,
      isCompleted: isCompleted ?? this.isCompleted,
      taskType: taskType ?? this.taskType,
    );
  }

  /// Check if task should be displayed today
  bool shouldDisplayToday() {
    // One-time tasks show only for today
    if (taskType == 'one_time') {
      return true;
    }
    // Other tasks always display
    return true;
  }
}
