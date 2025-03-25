import 'dart:async';
import 'dart:isolate';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Add this for WidgetsFlutterBinding
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:questra_app/core/services/secure_storage.dart';
import 'package:questra_app/features/lootbox/lootbox_manager.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:retry/retry.dart';
import 'package:workmanager/workmanager.dart';
import 'package:questra_app/imports.dart';

// Message class for communication between isolates
class BackgroundTaskMessage {
  final String taskName;
  final Map<String, dynamic>? inputData;
  final SendPort sendPort;

  BackgroundTaskMessage(this.taskName, this.inputData, this.sendPort);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Ensure Flutter bindings are initialized in the main isolate
    WidgetsFlutterBinding.ensureInitialized();

    // Spawn the isolate
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _backgroundIsolateEntry,
      BackgroundTaskMessage(taskName, inputData, receivePort.sendPort),
    );

    // Wait for result from isolate
    final completer = Completer<bool>();
    receivePort.listen((message) {
      if (message is bool) {
        completer.complete(message);
      }
    });

    return completer.future;
  });
}

@pragma('vm:entry-point')
void _backgroundIsolateEntry(BackgroundTaskMessage message) async {
  // Ensure Flutter bindings are initialized in the background isolate
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeSupabaseWithRetry();

    switch (message.taskName) {
      case 'questCheck':
        await Future.wait([
          _executeWithRetry(() => _sendSystemMessage(0), 'System message'),
          _executeWithRetry(_lootBoxTask, 'Lootbox task'),
        ], eagerError: false).then((results) {
          log("Background tasks completed with results: $results");
        });
        break;
    }
    message.sendPort.send(true);
  } catch (e) {
    final failed = "Background task failed: $e";
    log(failed);
    await ExceptionService.insertException(
      path: '/background_service',
      error: failed,
      userId: Supabase.instance.client.auth.currentUser?.id ?? "null",
    ).catchError((e) => log("Failed to log exception: $e"));
    message.sendPort.send(false);
  }
}

// Rest of your existing functions remain largely unchanged
Future<bool> _executeWithRetry(Future<void> Function() task, String taskName) async {
  try {
    await retry(
      () => task(),
      retryIf: (e) => e is! ArgumentError,
      maxAttempts: 3,
      delayFactor: const Duration(seconds: 1),
    );
    log("Successfully completed task: $taskName");
    return true;
  } catch (e) {
    log("Task $taskName failed after retries: $e");
    await ExceptionService.insertException(
      path: '/background_service/$taskName',
      error: e.toString(),
      userId: Supabase.instance.client.auth.currentUser?.id ?? "null",
    ).catchError((e) => log("Failed to log exception: $e"));
    return false;
  }
}

Future<void> _lootBoxTask() async {
  sendNotification("Loot Box Task Function", "test");
  final _client = Supabase.instance.client;
  final session = _client.auth.currentSession;
  if (session == null) return;

  final userId = session.user.id;

  sendNotification(userId, "test");
  final userData =
      await _client.from(TableNames.players).select("id").eq(KeyNames.id, userId).maybeSingle();

  if (userData == null) return;

  final lootBoxManager = LootBoxManager();
  await lootBoxManager.checkLootBoxDrop();
}

Future<void> _initializeSupabaseWithRetry() async {
  await retry(
    () => _initializeSupabase(),
    retryIf: (e) => e is! ArgumentError,
    maxAttempts: 3,
    delayFactor: const Duration(seconds: 1),
  );
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
        localStorage: secureStorage,
        detectSessionInUri: true,
        autoRefreshToken: true,
      ),
    );
    sendNotification("Supabase initialized", "test");
  } catch (e) {
    sendNotification(e.toString(), "test");

    log('Failed to initialize Supabase: $e');
    throw Exception(e);
  }
}

Future<void> _sendSystemMessage(int retry) async {
  final _client = Supabase.instance.client;
  final session = _client.auth.currentSession;

  if (retry >= 3) return;
  if (_client.auth.currentUser == null) {
    await _client.auth.refreshSession();
    return _sendSystemMessage(retry + 1);
  }
  if (session == null) return;

  final userId = session.user.id;
  final data = await _client.rpc(
    FunctionNames.get_today_notifications_count,
    params: {'p_user_id': userId},
  );

  int notificationCount =
      data is int
          ? data
          : data is String
          ? int.tryParse(data) ?? 0
          : 0;

  if (notificationCount > 6) {
    log('Maximum notifications reached for today');
    return;
  }

  await NotificationsRepository.sendNotificationFunction(userId);
}

Future<void> sendNotification(String body, String title) async {
  try {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'quest_channel',
      'Quest Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        '',
        htmlFormatBigText: true,
        htmlFormatContentTitle: true,
      ),
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

    await notifications.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
    await notifications.show(notificationId, title, body, platformDetails);
  } catch (e) {
    log('Failed to send notification: $e');
  }
}
