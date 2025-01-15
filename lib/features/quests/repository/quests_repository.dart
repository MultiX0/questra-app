import 'dart:developer';

import 'package:questra_app/core/enums/status_enum.dart';
import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/core/shared/constants/table_names.dart';
import 'package:questra_app/core/shared/utils/app_date_format.dart';
import 'package:questra_app/features/leveling/models/levels_model.dart';
import 'package:questra_app/features/leveling/repository/leveling_repository.dart';
import 'package:questra_app/features/quests/models/feedback_model.dart';
import 'package:questra_app/features/quests/models/quest_model.dart';
import 'package:questra_app/features/quests/models/quest_type_model.dart';
import 'package:questra_app/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final questsRepositoryProvider = Provider<QuestsRepository>((ref) {
  return QuestsRepository(ref: ref);
});

class QuestsRepository {
  final Ref _ref;
  QuestsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _questTypesTable => _client.from(TableNames.quest_types);
  SupabaseQueryBuilder get _playerQuestsTable => _client.from(TableNames.user_quests);
  SupabaseQueryBuilder get _questsFeedbackTable => _client.from(TableNames.user_feedback);

  final uuid = Uuid();

  Future<List<QuestTypeModel>> getAllQuestTypes() async {
    try {
      final data = await _questTypesTable.select('*');
      log("quest types: $data");
      final types = data.map((type) => QuestTypeModel.fromMap(type)).toList();
      return types;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<List<FeedbackModel>> getUserFeedbacks(String user_id) async {
    try {
      final data = await _questsFeedbackTable.select('''
      *,
      ${TableNames.user_quests}(
        user_quest_id,
        created_at,
        user_id,
        quest_description,
        xp_reward,
        coin_reward,
        difficulty,
        status,
        assigned_at,
        completed_at,
        estimated_completion_time
      )
    ''').eq('user_id', user_id);

      final feedbacks = data
          .map(
            (feedback) => FeedbackModel.fromMap(feedback).copyWith(
              quest: QuestModel.fromMap(
                feedback[TableNames.user_quests],
              ),
            ),
          )
          .toList();

      return feedbacks;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<List<QuestTypeModel>> getQuestTypesByIds(List<int>? ids) async {
    try {
      final data = await _questTypesTable.select('*').inFilter(KeyNames.id, ids ?? []);
      return data.map((q) => QuestTypeModel.fromMap(q)).toList();
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<int> questsDoneTodayCount(String user_id) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final data = await _playerQuestsTable
          .select('id')
          .eq('user_id', user_id)
          .gte('completed_at', todayStart)
          .lte('completed_at', todayEnd);

      return data.length;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<List<QuestModel>> currentlyOngoingQuests(String user_id) async {
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

  Future<List<QuestModel>> getLastUserQuests(String user_id) async {
    try {
      final data = await _playerQuestsTable
          .select('*')
          .eq(KeyNames.user_id, user_id)
          .order(KeyNames.created_at, ascending: false)
          .limit(5);

      return data.map((quest) => QuestModel.fromMap(quest)).toList();
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<String> insertQuest(QuestModel quest) async {
    try {
      final id = uuid.v4();
      final _quest = quest.copyWith(id: id);
      await _playerQuestsTable.insert(_quest.toMap());
      return id;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> finishQuest(QuestModel quest) async {
    try {
      final now = DateTime.now();
      final user = _ref.read(authStateProvider);
      if (now.isBefore(quest.expected_completion_time_date)) {
        throw Exception(
            "you need to wait until ${appDateFormat(quest.expected_completion_time_date)}");
      }

      if (now.add(Duration(hours: 3)).isAfter(quest.expected_completion_time_date)) {
        await _updateQuestStatus(StatusEnum.failed, quest.id);
        throw Exception('this quest is expired you will recive the penalties');
      }

      await _updateQuestStatus(StatusEnum.completed, quest.id);
      LevelsModel level = user?.level ?? LevelsModel(user_id: user!.id, level: 1, xp: 0);
      level.addXp(quest.xp_reward);

      await _updateUserLevel(user!.id, level);
      _ref.read(authStateProvider.notifier).updateState(user.copyWith(level: level));
    } catch (e) {
      log(e.toString());
      throw Exception("Please try again later...");
    }
  }

  Future<void> _updateUserLevel(String userId, LevelsModel levelModel) async {
    try {
      await _ref.read(levelingRepositoryProvider).updateUserLevelData(userId, levelModel);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> _updateQuestStatus(StatusEnum status, String questId) async {
    try {
      await _playerQuestsTable.update({KeyNames.status: status, KeyNames.user_quest_id: questId});
    } catch (e) {
      log(e.toString());
    }
  }

  // Future<>
}
