class Routine {
  final String id;
  final int hour;
  final String minutes;
  final String seconds;
  final bool isActive;

  Routine({
    required this.id,
    required this.hour,
    required this.minutes,
    required this.seconds,
    required this.isActive,
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      hour: map['hour'],
      minutes: map['minutes'],
      seconds: map['seconds'],
      isActive: map['isActive'],
    );
  }
}
