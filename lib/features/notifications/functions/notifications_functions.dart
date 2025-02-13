import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationsFunctions {
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

    // Set up the notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'quest_channel', // Channel ID
      'Quest Notifications', // Channel name
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Configure the timezone
    tz.initializeTimeZones();
    final tz.TZDateTime scheduledTZDateTime = _convertToTimeZone(scheduledTime);

    // Schedule the notification
    await notifications.zonedSchedule(
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      scheduledTZDateTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static tz.TZDateTime _convertToTimeZone(DateTime scheduledTime) {
    // Get the local timezone
    tz.setLocalLocation(tz.local);

    // Convert the given DateTime to TZDateTime
    return tz.TZDateTime.from(scheduledTime, tz.local);
  }
}
