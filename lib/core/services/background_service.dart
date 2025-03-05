import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:questra_app/core/services/secure_storage.dart';
import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/features/lootbox/lootbox_manager.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:workmanager/workmanager.dart';
import 'package:questra_app/imports.dart';

// Isolate-specific data structures
class IsolateTaskParams {
  final String userId;
  final String supabaseUrl;
  final String supabaseKey;

  IsolateTaskParams({required this.userId, required this.supabaseUrl, required this.supabaseKey});
}

class IsolateTaskResult {
  final bool success;
  final String? error;

  IsolateTaskResult({required this.success, this.error});
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Lightweight and fast initialization
      await _fastInitialize();

      switch (taskName) {
        case 'questCheck':
          await _performBackgroundTasks();
          break;
      }
      return Future.value(true);
    } catch (e) {
      await _handleBackgroundError(e);
      return Future.value(false);
    }
  });
}

Future<void> _fastInitialize() async {
  try {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize secure storage
    final secureStorage = SecureLocalStorage();
    await secureStorage.initialize();

    // Load environment configurations
    await dotenv.load(fileName: '.env');

    // Minimal Supabase initialization
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
    log('Fast initialization failed: $e');
    rethrow;
  }
}

Future<void> _performBackgroundTasks() async {
  final _client = Supabase.instance.client;
  final session = _client.auth.currentSession;

  if (session == null) return;

  final userId = session.user.id;
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? "";
  final supabaseKey = dotenv.env['SUPABASE_KEY'] ?? "";

  // Use Isolate for potentially heavy tasks
  final isolateParams = IsolateTaskParams(
    userId: userId,
    supabaseUrl: supabaseUrl,
    supabaseKey: supabaseKey,
  );

  // Run tasks potentially in separate isolates
  final tasks = [
    _runInIsolate(_checkSystemMessageTask, isolateParams),
    _runInIsolate(_processLootBoxTask, isolateParams),
  ];

  final results = await Future.wait(tasks);

  // Handle results if needed
  for (var result in results) {
    if (!result.success) {
      log('Background task failed: ${result.error}');
    }
  }
}

// Isolate-safe static method for system message check
@pragma('vm:entry-point')
Future<IsolateTaskResult> _checkSystemMessageTask(IsolateTaskParams params) async {
  try {
    // Reinitialize Supabase in the isolate
    await Supabase.initialize(url: params.supabaseUrl, anonKey: params.supabaseKey, debug: false);

    final _client = Supabase.instance.client;

    final data = await _client.rpc(
      FunctionNames.get_today_notifications_count,
      params: {'p_user_id': params.userId},
    );

    // Safely parse notification count
    final notificationCount = data is int ? data : int.tryParse(data.toString()) ?? 0;

    // Check if notification limit is exceeded
    if (notificationCount <= 6) {
      await NotificationsRepository.sendNotificationFunction(params.userId);
    }

    return IsolateTaskResult(success: true);
  } catch (e) {
    return IsolateTaskResult(success: false, error: e.toString());
  }
}

// Isolate-safe method for loot box processing
@pragma('vm:entry-point')
Future<IsolateTaskResult> _processLootBoxTask(IsolateTaskParams params) async {
  try {
    // Reinitialize Supabase in the isolate
    await Supabase.initialize(url: params.supabaseUrl, anonKey: params.supabaseKey, debug: false);

    final _client = Supabase.instance.client;

    // Fetch user data efficiently
    final userData =
        await _client
            .from(TableNames.players)
            .select("*")
            .eq(KeyNames.id, params.userId)
            .maybeSingle();

    if (userData == null) {
      return IsolateTaskResult(success: true);
    }

    final lootBoxManager = LootBoxManager();
    await lootBoxManager.checkLootBoxDrop();

    return IsolateTaskResult(success: true);
  } catch (e) {
    return IsolateTaskResult(success: false, error: e.toString());
  }
}

// Generic method to run tasks in an isolate
Future<IsolateTaskResult> _runInIsolate<P, R>(
  Future<IsolateTaskResult> Function(P) task,
  P params,
) async {
  final receivePort = ReceivePort();

  try {
    await Isolate.spawn(
      _isolateEntryPoint,
      _IsolateMessage(task: task, params: params, sendPort: receivePort.sendPort),
    );

    // Wait for the result from the isolate
    return await receivePort.first as IsolateTaskResult;
  } catch (e) {
    return IsolateTaskResult(success: false, error: e.toString());
  }
}

// Entry point for isolate communication
@pragma('vm:entry-point')
void _isolateEntryPoint(_IsolateMessage message) async {
  try {
    final result = await message.task(message.params);
    message.sendPort.send(result);
  } catch (e) {
    message.sendPort.send(IsolateTaskResult(success: false, error: e.toString()));
  }
}

// Helper class for isolate messaging
class _IsolateMessage<P> {
  final Future<IsolateTaskResult> Function(P) task;
  final P params;
  final SendPort sendPort;

  _IsolateMessage({required this.task, required this.params, required this.sendPort});
}

Future<void> _handleBackgroundError(dynamic error) async {
  log('Background task failed: $error');

  // Centralized error handling
  await ExceptionService.insertException(
    path: '/background_service',
    error: error.toString(),
    userId: Supabase.instance.client.auth.currentUser?.id ?? "null",
  );
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
