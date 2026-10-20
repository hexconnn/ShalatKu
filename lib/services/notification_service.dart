
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_schedule.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();

    final timezoneInfo =
    await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezoneInfo.identifier),
    );

    const settings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );

    await _plugin.initialize(settings: settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> schedulePrayerNotifications(
      PrayerSchedule schedule,
      ) async {
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_reminders',
        'Pengingat Shalat',
        channelDescription: 'Pengingat waktu shalat',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    for (var i = 0; i < schedule.prayers.length; i++) {
      final prayer = schedule.prayers[i];

      final scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        prayer.hour,
        prayer.minute,
      );

      if (scheduled.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: i + 1,
          title: 'Waktu Shalat ${prayer.name}',
          body: 'Saatnya menunaikan shalat ${prayer.name}.',
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
