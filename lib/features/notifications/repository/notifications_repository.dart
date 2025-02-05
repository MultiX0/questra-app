import 'dart:convert';
import 'dart:developer';

import 'package:questra_app/core/models/login_logs_model.dart';
import 'package:questra_app/core/services/background_service.dart';
import 'package:questra_app/features/quests/ai/ai_notifications.dart';
import 'package:questra_app/features/quests/ai/notifications_system_parts.dart';
import 'package:questra_app/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsRepository {
  static final _client = Supabase.instance.client;
  static SupabaseQueryBuilder get _logsTable => _client.from(TableNames.login_logs);
  static SupabaseQueryBuilder get _playerQuestsTable => _client.from(TableNames.user_quests);

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
      final now = DateTime.now();

      final perfectTimeToSent = prefs.getString("perfect_time_to_send");
      final nextPerfectTimeToSent = prefs.getString("next_perfect_time");
      final notificationText = prefs.getString("notification");

      if (perfectTimeToSent != null && perfectTimeToSent.isNotEmpty) {
        final date = DateTime.tryParse(perfectTimeToSent) ?? DateTime.now();
        if (now.isAfter(date) || now == date) {
          if (notificationText != null && notificationText.isNotEmpty) {
            await sendNotification(notificationText, "System");
            await prefs.setString("perfect_time_to_send", "");
          }
        }
        return;
      }

      if (nextPerfectTimeToSent != null && nextPerfectTimeToSent.isNotEmpty) {
        final date = DateTime.tryParse(nextPerfectTimeToSent) ?? DateTime.now();
        if (now.isAfter(date) || now == date) {
          final data = await _generatePrompt(userId);
          Map<String, dynamic> jsonData = jsonDecode(data);
          final PTTS = jsonData["perfect_time_to_send"];
          final NPTTS = jsonData["next_perfect_time"];
          final notification = jsonData["notification"];
          bool sentNow = jsonData["sent_now"];

          await prefs.setString("perfect_time_to_send", PTTS ?? "");
          await prefs.setString("next_perfect_time", NPTTS ?? "");
          await prefs.setString("notification", notification ?? "");

          if (sentNow) {
            await sendNotification(notification, "System");
          }
        }
        return;
      } else {
        final data = await _generatePrompt(userId);
        Map<String, dynamic> jsonData = jsonDecode(data);
        final PTTS = jsonData["perfect_time_to_send"];
        final NPTTS = jsonData["next_perfect_time"];
        final notification = jsonData["notification"];
        bool sentNow = jsonData["sent_now"];

        await prefs.setString("perfect_time_to_send", PTTS ?? "");
        await prefs.setString("next_perfect_time", NPTTS ?? "");
        await prefs.setString("notification", notification ?? "");

        if (sentNow) {
          await sendNotification(notification, "System");
        }
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static Future<String> _generatePrompt(String userId) async {
    try {
      final now = DateTime.now();
      final logsList = await _getUserLogs(userId);
      final onGoingQuests = await _currentlyOngoingQuests(userId);

      String prompt = '''
        current_time: ${now.toIso8601String()},
        last_user_open_app: ${logsList.map((l) => l.loggedAt).toList()},
        in_progress_quests: ${onGoingQuests.map((quest) => quest.toString())},
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
    try {
      final data = await _playerQuestsTable
          .select('*')
          .eq(KeyNames.status, 'in_progress')
          .eq(KeyNames.user_id, user_id);

      List<QuestModel> quests = data.map((quest) => QuestModel.fromMap(quest)).toList();
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
