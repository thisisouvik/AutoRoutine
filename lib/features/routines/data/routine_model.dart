class Routine {
  final String id;
  final int hour;
  final int minute;
  final String message;
  final bool isActive;

  Routine({
    required this.id,
    required this.hour,
    required this.minute,
    required this.message,
    required this.isActive,
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      hour: map['hour'],
      minute: map['minute'],
      message: map['message'],
      isActive: map['isActive'],
    );
  }
}
