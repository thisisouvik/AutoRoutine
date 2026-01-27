class Routine {
  final String id;
  final int hour;
  final int minute;
  final String message;
  final bool isActive;
  final String scheduleType;

  Routine({
    required this.id,
    required this.hour,
    required this.minute,
    required this.message,
    required this.isActive,
    this.scheduleType = 'General',
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'] as String,
      hour: (map['hour'] ?? map['hr']) as int,
      minute: (map['minute'] ?? map['min']) as int,
      message: map['message'] as String,
      isActive: (map['is_active'] ?? map['isActive'] ?? false) as bool,
      scheduleType: map['schedule_type'] as String? ?? 'General',
    );
  }
}
