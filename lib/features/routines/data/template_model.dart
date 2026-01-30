class TemplateRoutine {
  final int hour;
  final int min;
  final String message;
  final bool isActive;

  TemplateRoutine({
    required this.hour,
    required this.min,
    required this.message,
    required this.isActive,
  });

  factory TemplateRoutine.fromMap(Map<String, dynamic> map) {
    return TemplateRoutine(
      hour: (map['hour'] ?? map['hr'] ?? 0) as int,
      min: (map['min'] ?? map['minute'] ?? 0) as int,
      message: map['message'] as String,
      isActive: (map['is_active'] ?? map['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'min': min,
      'message': message,
      'is_active': isActive,
    };
  }
}

class RoutineTemplate {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String scheduleType;
  final List<TemplateRoutine> routines;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoutineTemplate({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.scheduleType = 'General',
    required this.routines,
    required this.createdAt,
    this.updatedAt,
  });

  factory RoutineTemplate.fromMap(Map<String, dynamic> map) {
    return RoutineTemplate(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      scheduleType: map['schedule_type'] as String? ?? 'General',
      routines: [], // Will be populated separately
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'schedule_type': scheduleType,
    };
  }
}
