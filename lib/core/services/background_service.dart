import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:questra_app/core/services/secure_storage.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:workmanager/workmanager.dart';
import 'package:questra_app/imports.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await _initializeSupabase();
    await _checkExpiringQuests();
    await _sendSystemMessage();
    return true;
  });
}

final _url = dotenv.env['SUPABASE_URL'] ?? "";
final _key = dotenv.env['SUPABASE_KEY'] ?? "";

Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: _url,
      anonKey: _key,
      debug: kDebugMode,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureLocalStorage(),
      ),
    );
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<void> _sendSystemMessage() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  final userId = session.user.id;

  await NotificationsRepository.sendNotificationFunction(userId);
}

Future<void> _checkExpiringQuests() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  final userId = session.user.id;
  final now = DateTime.now().toUtc();

  final response = await Supabase.instance.client
      .from('user_quests')
      .select()
      .eq('user_id', userId)
      .eq('status', 'in_progress')
      .lt('expected_completion_time_date', now.add(const Duration(hours: 2)))
      .gt('expected_completion_time_date', now)
      .or('notified_two_hours.is.false,notified_one_hour.is.false');

  for (final quest in response) {
    final expectedTime = DateTime.parse(quest['expected_completion_time_date']).toUtc();
    final timeLeft = expectedTime.difference(now);

    if (timeLeft <= const Duration(hours: 2) && !quest['notified_two_hours']) {
      sendNotification('2 hours left to complete "${quest['quest_title']}"', quest['quest_title']);
      await _updateNotificationStatus(quest['user_quest_id'], 'notified_two_hours');
    }

    if (timeLeft <= const Duration(hours: 1) && !quest['notified_one_hour']) {
      sendNotification('1 hour left to complete "${quest['quest_title']}"', quest['quest_title']);
      await _updateNotificationStatus(quest['user_quest_id'], 'notified_one_hour');
    }
  }
}

Future<void> _updateNotificationStatus(String questId, String column) async {
  await Supabase.instance.client
      .from('user_quests')
      .update({column: true}).eq('user_quest_id', questId);
}

Future<void> sendNotification(String body, String title) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'quest_channel',
    'Quest Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  ));

  await notifications.show(0, title, body, platformDetails);
}
