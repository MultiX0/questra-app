import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:questra_app/core/services/secure_storage.dart';
import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/features/lootbox/lootbox_manager.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:retry/retry.dart';
import 'package:workmanager/workmanager.dart';
import 'package:questra_app/imports.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized(); // Required for plugins

    try {
      // Initialize Supabase with retry logic
      await _initializeSupabaseWithRetry();

      switch (taskName) {
        case 'questCheck':
          // Execute tasks independently
          await Future.wait([
            _executeWithRetry(() => _sendSystemMessage(0), 'System message'),
            _executeWithRetry(_lootBoxTask, 'Lootbox task'),
          ], eagerError: false).then((results) {
            // Log results but don't fail the entire task if some parts failed
            log("Background tasks completed with results: $results");
          });
          break;
      }
      return Future.value(true);
    } catch (e) {
      final failed = "Background task failed: $e";
      log(failed);
      await ExceptionService.insertException(
        path: '/background_service',
        error: failed,
        userId: Supabase.instance.client.auth.currentUser?.id ?? "null",
      ).catchError((e) => log("Failed to log exception: $e"));

      return Future.value(false);
    }
  });
}

// Execute a function with retry logic
Future<bool> _executeWithRetry(Future<void> Function() task, String taskName) async {
  try {
    await retry(
      () => task(),
      retryIf: (e) => e is! ArgumentError, // Don't retry if the error is fundamental
      maxAttempts: 3,
      delayFactor: const Duration(seconds: 1),
    );
    log("Successfully completed task: $taskName");
    return true;
  } catch (e) {
    log("Task $taskName failed after retries: $e");

    // Log the error but don't make the entire process fail
    await ExceptionService.insertException(
      path: '/background_service/$taskName',
      error: e.toString(),
      userId: Supabase.instance.client.auth.currentUser?.id ?? "null",
    ).catchError((e) => log("Failed to log exception: $e"));

    return false;
  }
}

Future<void> _lootBoxTask() async {
  final _client = Supabase.instance.client;
  final session = _client.auth.currentSession;
  if (session == null) return;

  final userId = session.user.id;

  // Optimize query by selecting only needed fields
  final userData =
      await _client.from(TableNames.players).select("id").eq(KeyNames.id, userId).maybeSingle();

  if (userData == null) return;

  final lootBoxManager = LootBoxManager();
  await lootBoxManager.checkLootBoxDrop();
}

Future<void> _initializeSupabaseWithRetry() async {
  await retry(
    () => _initializeSupabase(),
    retryIf: (e) => e is! ArgumentError, // Don't retry if env vars are missing
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
  } catch (e) {
    log('Failed to initialize Supabase: $e');
    throw Exception(e);
  }
}

Future<void> _sendSystemMessage(int retry) async {
  final _client = Supabase.instance.client;
  final session = _client.auth.currentSession;

  if (retry >= 3) {
    return;
  }
  if (_client.auth.currentUser == null) {
    await _client.auth.refreshSession();
    return _sendSystemMessage(retry++);
  }

  if (session == null) return;

  final userId = session.user.id;

  // Fetch notification count
  final data = await _client.rpc(
    FunctionNames.get_today_notifications_count,
    params: {'p_user_id': userId},
  );

  int notificationCount;
  if (data is int) {
    notificationCount = data;
  } else if (data is String) {
    notificationCount = int.tryParse(data) ?? 0;
  } else {
    notificationCount = 0;
  }

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

    // Use timestamp for unique notification ID
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    await notifications.show(notificationId, title, body, platformDetails);
  } catch (e) {
    log('Failed to send notification: $e');
  }
}
