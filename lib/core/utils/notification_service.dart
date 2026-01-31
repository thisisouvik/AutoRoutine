import 'dart:convert';

import 'package:autoroutine/features/routines/data/routine_model.dart';
import 'package:autoroutine/features/routines/data/routine_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'routine_channel';
  static const String _channelName = 'Routine reminders';
  static const String _channelDescription =
      'Reminders for upcoming and overdue routines';

  static const String actionComplete = 'action_complete';
  static const String actionDismiss = 'action_dismiss';

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timezoneData = await FlutterTimezone.getLocalTimezone();
      final timezoneName = timezoneData
          .toString()
          .replaceAll('TimezoneInfo(', '')
          .replaceAll(')', '');
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      // Fallback to default timezone
      tz.setLocalLocation(tz.local);
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
          ),
        );

    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> _onNotificationResponse(
    NotificationResponse response,
  ) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final data = jsonDecode(payload) as Map<String, dynamic>;
    final routineId = data['routineId'] as String?;
    if (routineId == null) return;

    if (response.actionId == actionComplete) {
      await RoutineRepository().toggleRoutineCompletion(routineId, true);
      await cancelAllForRoutine(routineId);
      return;
    }

    if (response.actionId == actionDismiss) {
      await RoutineRepository().toggleRoutineCompletion(routineId, false);
      // Cancel only the current notification; nightly reminder stays.
      if (response.id != null) {
        await _notifications.cancel(response.id!);
      }
    }
  }

  static Future<void> syncRoutineNotifications(List<Routine> routines) async {
    for (final routine in routines) {
      if (!_isEligibleForNotification(routine)) {
        await cancelAllForRoutine(routine.id);
        continue;
      }

      if (routine.isCompleted) {
        await cancelAllForRoutine(routine.id);
        continue;
      }

      await _scheduleRoutineNotifications(routine);
    }
  }

  static bool _isEligibleForNotification(Routine routine) {
    if (!routine.isActive) return false;
    if (routine.taskType == 'template') return false;
    return _isUuid(routine.id);
  }

  static bool _isUuid(String value) {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(value);
  }

  static Future<void> cancelAllForRoutine(String routineId) async {
    await _notifications.cancel(_notificationId(routineId, 'pre'));
    await _notifications.cancel(_notificationId(routineId, 'time'));
    await _notifications.cancel(_notificationId(routineId, 'night'));

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await _notifications.cancel(_notificationId(routineId, 'pre-$weekday'));
      await _notifications.cancel(_notificationId(routineId, 'time-$weekday'));
    }
  }

  static Future<void> _scheduleRoutineNotifications(Routine routine) async {
    final days = _parseDays(routine.scheduleFrequency);

    if (days.isEmpty) {
      // Daily schedule
      await _scheduleDaily(routine, isPreReminder: true);
      await _scheduleDaily(routine, isPreReminder: false);
      await _scheduleNightlyReminder(routine);
      return;
    }

    // Specific days schedule
    for (final day in days) {
      await _scheduleWeekly(routine, day, isPreReminder: true);
      await _scheduleWeekly(routine, day, isPreReminder: false);
    }
    await _scheduleNightlyReminder(routine);
  }

  static Future<void> _scheduleDaily(
    Routine routine, {
    required bool isPreReminder,
  }) async {
    final scheduledTime = _nextDailyTime(
      routine.hour,
      routine.minute,
      isPreReminder: isPreReminder,
    );

    await _notifications.zonedSchedule(
      _notificationId(routine.id, isPreReminder ? 'pre' : 'time'),
      isPreReminder ? 'Upcoming in 5 minutes' : 'Time for ${routine.message}',
      isPreReminder
          ? 'Get ready for ${routine.message}'
          : 'Tap Completed or Dismiss',
      scheduledTime,
      _notificationDetails(ongoing: !isPreReminder),
      payload: jsonEncode({'routineId': routine.id}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> _scheduleWeekly(
    Routine routine,
    int weekday, {
    required bool isPreReminder,
  }) async {
    final scheduledTime = _nextWeeklyTime(
      weekday,
      routine.hour,
      routine.minute,
      isPreReminder: isPreReminder,
    );

    await _notifications.zonedSchedule(
      _notificationId(
        routine.id,
        isPreReminder ? 'pre-$weekday' : 'time-$weekday',
      ),
      isPreReminder ? 'Upcoming in 5 minutes' : 'Time for ${routine.message}',
      isPreReminder
          ? 'Get ready for ${routine.message}'
          : 'Tap Completed or Dismiss',
      scheduledTime,
      _notificationDetails(ongoing: !isPreReminder),
      payload: jsonEncode({'routineId': routine.id}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> _scheduleNightlyReminder(Routine routine) async {
    final scheduledTime = _nextDailyTime(22, 0, isPreReminder: false);

    await _notifications.zonedSchedule(
      _notificationId(routine.id, 'night'),
      'Incomplete task reminder',
      "${routine.message} is still incomplete",
      scheduledTime,
      _notificationDetails(ongoing: true),
      payload: jsonEncode({'routineId': routine.id}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static NotificationDetails _notificationDetails({required bool ongoing}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        ongoing: ongoing,
        autoCancel: !ongoing,
        actions: [
          const AndroidNotificationAction(actionComplete, 'Completed'),
          const AndroidNotificationAction(actionDismiss, 'Dismiss'),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );
  }

  static tz.TZDateTime _nextDailyTime(
    int hour,
    int minute, {
    required bool isPreReminder,
  }) {
    var scheduled = tz.TZDateTime(
      tz.local,
      tz.TZDateTime.now(tz.local).year,
      tz.TZDateTime.now(tz.local).month,
      tz.TZDateTime.now(tz.local).day,
      hour,
      minute,
    );

    if (isPreReminder) {
      scheduled = scheduled.subtract(const Duration(minutes: 5));
    }

    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _nextWeeklyTime(
    int weekday,
    int hour,
    int minute, {
    required bool isPreReminder,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (isPreReminder) {
      scheduled = scheduled.subtract(const Duration(minutes: 5));
    }

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static List<int> _parseDays(String scheduleFrequency) {
    final match = RegExp(r'\((.*?)\)').firstMatch(scheduleFrequency);
    if (match == null) return [];

    final daysText = match.group(1) ?? '';
    final parts = daysText.split(',').map((p) => p.trim()).toList();

    final map = <String, int>{
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    return parts
        .where(map.containsKey)
        .map((p) => map[p]!)
        .toList(growable: false);
  }

  static int _notificationId(String routineId, String type) {
    final hash = routineId.hashCode & 0x7fffffff;
    final parts = type.split('-');
    final baseType = parts.first;
    final day = parts.length > 1 ? int.tryParse(parts.last) ?? 0 : 0;
    final typeOffset = switch (baseType) {
      'pre' => 1,
      'time' => 2,
      'night' => 3,
      _ => 0,
    };
    return hash + typeOffset + (day * 10);
  }
}
