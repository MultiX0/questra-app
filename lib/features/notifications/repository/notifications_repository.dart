import 'dart:convert';
import 'dart:developer';

import 'package:questra_app/core/models/login_logs_model.dart';
import 'package:questra_app/core/services/background_service.dart';
import 'package:questra_app/core/services/notifications_service.dart';
import 'package:questra_app/features/quests/ai/ai_notifications.dart';
import 'package:questra_app/features/quests/ai/notifications_system_parts.dart';
import 'package:questra_app/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsRepository {
  static final _client = Supabase.instance.client;
  static SupabaseQueryBuilder get _logsTable => _client.from(TableNames.login_logs);
  static SupabaseQueryBuilder get _playerQuestsTable => _client.from(TableNames.user_quests);
  static SupabaseQueryBuilder get _notificationLogs => _client.from(TableNames.notification_logs);
  static SupabaseQueryBuilder get _tokensTable => _client.from(TableNames.notification_tokens);

  static Future<bool> insertedToken(String userId, String token) async {
    try {
      final data = await _tokensTable
          .select("*")
          .eq(KeyNames.user_id, userId)
          .eq(KeyNames.token, token)
          .limit(1);

      return data.isNotEmpty;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<void> insertFCMToken(String userId) async {
    try {
      final fcmToken = await NotificationsService.getFCMToken();
      log("FCM TOKEN: $fcmToken");
      final inserted = await insertedToken(userId, fcmToken ?? "");
      if (inserted) return;

      await _tokensTable.insert({KeyNames.user_id: userId, KeyNames.token: fcmToken});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<void> insertLog(final String userId) async {
    try {
      final logsModel = LoginLogsModel(id: -1, userId: userId, loggedAt: DateTime.now());
      await _logsTable.insert(logsModel.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<void> sendNotificationFunction(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toUtc();
      final _userId = prefs.getString(KeyNames.user_id) ?? userId;

      // 1. Check for scheduled notifications ready to send
      final scheduledTimeMillis = prefs.getInt("perfect_time_to_send");
      if (scheduledTimeMillis != null && scheduledTimeMillis != 0) {
        final scheduledTime = DateTime.fromMillisecondsSinceEpoch(scheduledTimeMillis).toUtc();
        if (now.isAfter(scheduledTime) || now.isAtSameMomentAs(scheduledTime)) {
          final notification = prefs.getString("notification");
          if (notification?.isNotEmpty == true) {
            await sendNotification(notification!, "System");
            await prefs.setInt("perfect_time_to_send", 0); // Clear after sending
            final n = _createNotificationModel(
              userId: userId,
              notification: notification,
              sentNow: true,
              perfectTime: null,
              nextTime: scheduledTime,
            );
            await insertNotificationLog(n);
          }
          return;
        }
      }

      // 2. Check if we need to generate new notification
      final nextCheckMillis = prefs.getInt("next_perfect_time");
      DateTime? nextCheckTime;
      if (nextCheckMillis != null && nextCheckMillis != 0) {
        nextCheckTime = DateTime.fromMillisecondsSinceEpoch(nextCheckMillis).toUtc();
      }

      final shouldGenerate = nextCheckTime == null ||
          nextCheckMillis == 0 ||
          now.isAfter(nextCheckTime) ||
          now.isAtSameMomentAs(nextCheckTime);

      if (shouldGenerate) {
        // 3. Generate new notification data
        final response = await _generatePrompt(_userId);
        final jsonData = jsonDecode(response) as Map<String, dynamic>;

        // 4. Parse and validate response
        final notification = jsonData["notification"] as String;
        final sentNow = _parseSentNow(jsonData["sent_now"]);
        final ptts = _parseDateTime(jsonData["perfect_time_to_send"]);
        final nptt = _parseDateTime(jsonData["next_perfect_time"], required: true)!;

        // 5. Store new timing information
        await prefs.setInt("perfect_time_to_send", ptts?.millisecondsSinceEpoch ?? 0);
        await prefs.setInt("next_perfect_time", nptt.millisecondsSinceEpoch);
        await prefs.setString("notification", notification);

        // 6. Log and send if immediate
        final model = _createNotificationModel(
          userId: _userId,
          notification: notification,
          sentNow: sentNow,
          perfectTime: ptts,
          nextTime: nptt,
        );

        await insertNotificationLog(model);
        if (sentNow) await sendNotification(notification, "System");
      }
    } catch (e) {
      log('Notification Error: $e');
      final prefs = await SharedPreferences.getInstance();
      await _storeFallbackNotification(prefs);
    }
  }

  static Future<void> _storeFallbackNotification(SharedPreferences prefs) async {
    await prefs.setString(
        "notification", "🚀 Ready for your next adventure? Tap to continue your journey!");
    await prefs.setInt(
        "next_perfect_time", DateTime.now().toUtc().add(Duration(hours: 2)).millisecondsSinceEpoch);
  }

  static bool _parseSentNow(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime? _parseDateTime(dynamic value, {bool required = false}) {
    if (value == null || value == 'null') return null;
    try {
      return DateTime.parse(value as String).toUtc();
    } catch (e) {
      if (required) throw FormatException('Invalid datetime: $value');
      return null;
    }
  }

  static Map<String, dynamic> _createNotificationModel({
    required String userId,
    required String notification,
    required bool sentNow,
    required DateTime? perfectTime,
    required DateTime nextTime,
  }) {
    return {
      KeyNames.user_id: userId,
      KeyNames.notification: notification,
      KeyNames.sent_now: sentNow,
      KeyNames.perfect_time_to_send: perfectTime?.toIso8601String(),
      KeyNames.next_perfect_time: nextTime.toIso8601String(),
      'generated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static Future<void> insertNotificationLog(Map<String, dynamic> notification) async {
    try {
      await _notificationLogs.insert(notification);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<List<QuestModel>> _getFailedQuests(String userId) async {
    final now = DateTime.now();
    final data = await _playerQuestsTable
        .select("*")
        .eq(KeyNames.user_id, userId)
        .eq(KeyNames.status, StatusEnum.in_progress.name)
        .gte(KeyNames.expected_completion_time_date, now.toIso8601String());

    return data.map((q) => QuestModel.fromMap(q)).toList();
  }

  static Future<String> _generatePrompt(String userId) async {
    try {
      final now = DateTime.now();
      final logsList = await _getUserLogs(userId);
      final onGoingQuests = await _currentlyOngoingQuests(userId);
      final failedQuests = await _getFailedQuests(userId);

      String prompt = '''
        current_time: ${now.toIso8601String()},
        last_user_open_app: ${logsList.map((l) => l.loggedAt).toList()},
        in_progress_quests: ${onGoingQuests.map((quest) => quest.toString())},
        failed_quests: ${failedQuests.map((quest) => quest.toString())},
        current_user_time: ${now.toUtc().toIso8601String()}
        ''';

      final res = await AiNotifications.makeAiResponse(
        maxTokens: 500,
        content: [
          {"role": "user", "content": prompt},
          ...lifeImprovementSystemPrompts,
        ],
      );

      return res;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static Future<List<QuestModel>> _currentlyOngoingQuests(String user_id) async {
    final data = await _playerQuestsTable
        .select('*')
        .eq(KeyNames.status, 'in_progress')
        .eq(KeyNames.user_id, user_id);

    List<QuestModel> quests = data.map((quest) => QuestModel.fromMap(quest)).toList();
    try {
      return quests;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static Future<List<LoginLogsModel>> _getUserLogs(String userId) async {
    try {
      final data = await _logsTable.select("*").eq(KeyNames.user_id, userId);
      List<LoginLogsModel> list = data.map((l) => LoginLogsModel.fromMap(l)).toList();
      return list;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
