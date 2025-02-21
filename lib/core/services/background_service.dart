import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:questra_app/core/services/secure_storage.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:workmanager/workmanager.dart';
import 'package:questra_app/imports.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized(); // Required for plugins

    try {
      switch (taskName) {
        case 'questCheck':
          await _initializeSupabase();
          // await _checkExpiringQuests();
          await _sendSystemMessage();

          // Always send a test notification to verify background execution
          // await sendNotification(
          //     "Background Task", "Background task executed at ${DateTime.now()}");
          break;
      }
      return Future.value(true);
    } catch (e) {
      final failed = "Background task failed: $e";
      log(failed);
      await ExceptionService.insertException(
          path: '/background_service',
          error: failed,
          userId: Supabase.instance.client.auth.currentUser?.id ?? "null");

      // await sendNotification("Background task failed", e.toString());

      return Future.value(false);
    }
  });
}

Future<void> _initializeSupabase() async {
  try {
    final secureStorage = SecureLocalStorage();
    await secureStorage.initialize();

    await dotenv.load(fileName: '.env');

    final _url = dotenv.env['SUPABASE_URL'] ?? "";
    final _key = dotenv.env['SUPABASE_KEY'] ?? "";

    await Supabase.initialize(
      url: _url,
      anonKey: _key,
      debug: kDebugMode,
      authOptions: FlutterAuthClientOptions(
          localStorage: secureStorage, detectSessionInUri: true, autoRefreshToken: true),
    );
  } catch (e) {
    log('Failed to initialize Supabase: $e');
    throw Exception(e);
  }
}

Future<void> _sendSystemMessage() async {
  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final userId = session.user.id;

    await NotificationsRepository.sendNotificationFunction(userId);
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

// Future<void> _checkExpiringQuests() async {
// try {
// final session = Supabase.instance.client.auth.currentSession;
// if (session == null) return;

// final userId = session.user.id;
// final now = DateTime.now().toUtc();

// final response = await Supabase.instance.client
//     .from('user_quests')
//     .select()
//     .eq('user_id', userId)
//     .eq('status', 'in_progress')
//     .lt('expected_completion_time_date', now.add(const Duration(hours: 2)))
//     .gt('expected_completion_time_date', now)
//     .or('notified_two_hours.is.false,notified_one_hour.is.false');

// for (final quest in response) {
//   final expectedTime = DateTime.parse(quest['expected_completion_time_date']).toUtc();
//   final timeLeft = expectedTime.difference(now);

//   if (timeLeft <= const Duration(hours: 2) && !quest['notified_two_hours']) {
//     sendNotification(
//         '2 hours left to complete "${quest['quest_title']}"', quest['quest_title']);
//     await _updateNotificationStatus(quest['user_quest_id'], 'notified_two_hours');
//   }

//   if (timeLeft <= const Duration(hours: 1) && !quest['notified_one_hour']) {
//     sendNotification('1 hour left to complete "${quest['quest_title']}"', quest['quest_title']);
//     await _updateNotificationStatus(quest['user_quest_id'], 'notified_one_hour');
//   }
// }
//   } catch (e) {
//     log(e.toString());
//     rethrow;
//   }
// }

// Future<void> _updateNotificationStatus(String questId, String column) async {
//   await Supabase.instance.client
//       .from('user_quests')
//       .update({column: true}).eq('user_quest_id', questId);
// }

Future<void> sendNotification(String body, String title) async {
  try {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'quest_channel',
      'Quest Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

    await notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await notifications.show(
      DateTime.now().millisecond, // unique ID for each notification
      title,
      body,
      platformDetails,
    );
  } catch (e) {
    log('Failed to send notification: $e');
  }
}
