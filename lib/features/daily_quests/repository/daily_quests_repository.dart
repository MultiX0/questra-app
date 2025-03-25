import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:questra_app/features/daily_quests/models/daily_quest_model.dart';
import 'package:questra_app/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyQuestsRepository {
  final _client = Supabase.instance.client;
  SupabaseQueryBuilder get _dailyQuestSubmissionTable =>
      _client.from(TableNames.daily_quests_submission);

  Future<DailyQuestModel> getQuest(String userId) async {
    try {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final questData = prefs.getString("current_daily_quest");
      log('quest data is $questData');

      if (questData != null && questData.isNotEmpty) {
        final _json = jsonDecode(questData) as Map<String, dynamic>;
        return DailyQuestModel.fromLocal(_json);
      }

      final token = RootIsolateToken.instance;
      log(token.toString());
      BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
      final refreshedToken = _client.auth.currentSession!.refreshToken;
      DailyQuestModel quest = await computeIsolate(_fetchDailyQuest, {
        'id': userId,
        'supabaseUrl': dotenv.env['SUPABASE_URL'] ?? "",
        'supabaseKey': dotenv.env['SUPABASE_KEY'] ?? "",
        'token': refreshedToken,
      });

      log(quest.toString());

      if (quest.createdAt!.add(const Duration(hours: 6)).isBefore(now)) {
        final val = jsonEncode(quest.toLocal());
        await prefs.setString('current_daily_quest', val);
      } else {
        await prefs.setString('current_daily_quest', '');
      }

      return quest;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> completeQuest(DailyQuestModel quest) async {
    try {
      await _dailyQuestSubmissionTable.insert(quest.toLocal());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

Future _fetchDailyQuest(dynamic args) async {
  try {
    final now = DateTime.now().toUtc();
    final id = args['id'];
    final supabaseUrl = args['supabaseUrl'];
    final supabaseKey = args['supabaseKey'];
    final token = args['token'];
    final client = SupabaseClient(supabaseUrl, supabaseKey);
    await client.auth.setSession(token);

    final data = await client
        .from(TableNames.daily_quests_submission)
        .select("*")
        .eq(KeyNames.user_id, id)
        .order(KeyNames.created_at, ascending: false)
        .limit(14);

    if (data.isEmpty || data.length == 1) {
      return DailyQuestModel(
        id: -1,
        userId: id,
        pushUps: pushUpsBase,
        createdAt: now,
        setUps: setUpsBase,
        kmRun: runningBase,
        squats: sqautsBase,
      );
    }

    final quests = data.map((quest) => DailyQuestModel.fromLocal(quest)).toList();
    if (quests.first.createdAt!.add(const Duration(hours: 6)).isAfter(now)) {
      return quests.first;
    }

    return prepareNewQuest(quests, id);
  } catch (e, trace) {
    log(e.toString(), stackTrace: trace);
  }
}

DailyQuestModel prepareNewQuest(List<DailyQuestModel> quests, String userId) {
  int pushUps =
      calcAvg(quests.map((q) => q.pushUpsIdid!.toDouble()).toList(), quests.length).toInt();
  int setUps =
      calcAvg(quests.map((q) => q.pushUpsIdid!.toDouble()).toList(), quests.length).toInt();
  int squats =
      calcAvg(quests.map((q) => q.pushUpsIdid!.toDouble()).toList(), quests.length).toInt();
  double running = calcAvg(quests.map((q) => q.runningIdid!).toList(), quests.length);

  final wholeSetAvg = (pushUps + setUps + squats + running) / 4;

  if (quests.length > 10 && wholeSetAvg > 40) {
    pushUps += (pushUps / 2).toInt();
    setUps += (setUps / 2).toInt();
    squats += (squats / 2).toInt();
    running += (running / 2);
  }

  return DailyQuestModel(
    id: -1,
    userId: userId,
    pushUps: pushUps,
    setUps: setUps,
    createdAt: DateTime.now(),
    kmRun: running,
    squats: squats,
  );
}

double calcAvg(List<double> values, int length) {
  if (length == 0) return 0.0;
  double val = 0.0;
  for (final _val in values) {
    val += _val;
  }

  return val / length;
}
