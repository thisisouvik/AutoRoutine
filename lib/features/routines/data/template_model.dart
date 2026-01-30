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
  final String? category; // e.g., "Celebrity Routine" or null for personal
  final String? description;
  final String scheduleType;
  final bool isActive; // Whether template is activated
  final bool isPredefined; // Whether it's a celebrity/system template
  final List<TemplateRoutine> routines;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoutineTemplate({
    required this.id,
    required this.userId,
    required this.name,
    this.category,
    this.description,
    this.scheduleType = 'General',
    this.isActive = false,
    this.isPredefined = false,
    required this.routines,
    required this.createdAt,
    this.updatedAt,
  });

  factory RoutineTemplate.fromMap(Map<String, dynamic> map) {
    return RoutineTemplate(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
      description: map['description'] as String?,
      scheduleType: map['schedule_type'] as String? ?? 'General',
      isActive: map['is_active'] as bool? ?? false,
      isPredefined: map['is_predefined'] as bool? ?? false,
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
      'category': category,
      'description': description,
      'schedule_type': scheduleType,
      'is_active': isActive,
      'is_predefined': isPredefined,
    };
  }

  RoutineTemplate copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? description,
    String? scheduleType,
    bool? isActive,
    bool? isPredefined,
    List<TemplateRoutine>? routines,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineTemplate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      scheduleType: scheduleType ?? this.scheduleType,
      isActive: isActive ?? this.isActive,
      isPredefined: isPredefined ?? this.isPredefined,
      routines: routines ?? this.routines,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
