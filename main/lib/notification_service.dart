import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'canal_reminder',
    'Reminder Pastile',
    channelDescription: 'Trimite notificări la ore programate',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    ticker: 'Reminder pastile',
  );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidDetails,
  );

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleOrShowNow(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now.add(const Duration(seconds: 60)))) {
      await _notificationsPlugin.show(
        1,
        'Reminder pastile',
        'Este timpul să-ți iei pastilele 💊',
        _notificationDetails,
      );
    } else {
      await _notificationsPlugin.zonedSchedule(
        0,
        'Reminder pastile',
        'Este timpul să-ți iei pastilele 💊',
        scheduledDate,
        _notificationDetails,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'reminder',
      );
    }
  }

  static Future<void> scheduleRepeatedNotifications({
    required Duration interval,
    required Duration totalDuration,
    required int startHour,
    required int startMinute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var start = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      startHour,
      startMinute,
    );

    if (start.isBefore(now)) {
      start = start.add(Duration(days: 1));
    }

    final end = start.add(totalDuration);
    int id = 100;

    for (var time = start; time.isBefore(end); time = time.add(interval)) {
      await _notificationsPlugin.zonedSchedule(
        id++,
        'Reminder pastile',
        'Este timpul să-ți iei pastila nr. ${id - 100} 💊',
        time,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: 'recurent',
      );
    }
  }
}
