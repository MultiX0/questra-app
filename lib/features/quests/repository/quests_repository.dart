import 'dart:developer';

import 'package:questra_app/core/shared/utils/levels_calc.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
import 'package:questra_app/imports.dart';

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

  Future<List<QuestModel>> getQuestsArchive(String user_id) async {
    try {
      final data =
          await _playerQuestsTable.select("*").neq(KeyNames.status, StatusEnum.in_progress.name);
      final quests = data.map((quest) => QuestModel.fromMap(quest)).toList();
      return quests;
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

  Future<QuestModel?> getQuestById(String questId) async {
    try {
      final data =
          await _playerQuestsTable.select("*").eq(KeyNames.user_quest_id, questId).maybeSingle();
      if (data == null) {
        throw "the quest is not found";
      }
      final questData = QuestModel.fromMap(data);
      return questData;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<QuestModel> finishQuest({required QuestModel quest, FeedbackModel? feedback}) async {
    try {
      final unix = DateTime.now().millisecondsSinceEpoch;
      final now = DateTime.now();
      final user = _ref.read(authStateProvider);
      final expectedTimestamp = quest.expected_completion_time_date.millisecondsSinceEpoch;
      final expiryTimestamp = expectedTimestamp + (3 * 60 * 60 * 1000);

      final _quest = await getQuestById(quest.id);
      if (_quest?.status.trim() == StatusEnum.completed.name) {
        throw 'This quest is already completed';
      }

      if (feedback != null) {
        await insertFeedback(feedback);
      }

      if (now.isBefore(quest.expected_completion_time_date)) {
        throw "you need to wait until ${appDateFormat(quest.expected_completion_time_date)}";
      }

      if (unix > expiryTimestamp) {
        await _updateQuestStatus(StatusEnum.failed, quest.id);
        throw 'this quest is expired you will receive the penalties';
      }

      final updatedQuest = quest.copyWith(
        status: StatusEnum.completed.name,
        completed_at: DateTime.now(),
      );

      await updateQuest(updatedQuest);

      LevelsModel level = user?.level ?? LevelsModel(user_id: user!.id, level: 1, xp: 0);
      final levelData = addXp(quest.xp_reward, {
        "xp": level.xp,
        "level": level.level,
      });

      level = level.copyWith(xp: levelData['xp'], level: levelData['level']);
      await _updateUserLevel(user!.id, level);
      await _updateUserCoins(user: user, quest: updatedQuest);

      _ref.read(authStateProvider.notifier).updateState(user.copyWith(level: level));
      return updatedQuest;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> _updateUserCoins({required UserModel user, required QuestModel quest}) async {
    try {
      final coins = calculateQuestCoins(
        user.level?.level ?? 1,
        quest.difficulty,
      );

      await _ref.read(walletRepositoryProvider).addCoins(
            userId: user.id,
            amount: coins,
          );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _updateUserLevel(String userId, LevelsModel levelModel) async {
    try {
      await _ref.read(levelingRepositoryProvider).updateUserLevelData(levelModel);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> _updateQuestStatus(StatusEnum status, String questId) async {
    try {
      await _playerQuestsTable
          .update({KeyNames.status: status.name, KeyNames.user_quest_id: questId}).eq(
              KeyNames.user_quest_id, questId);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateQuest(QuestModel quest) async {
    try {
      final questMap = quest.toMap();
      questMap.remove(KeyNames.user_quest_id);

      await _playerQuestsTable.update(questMap).eq(KeyNames.user_quest_id, quest.id);
    } catch (e) {
      log(e.toString());
      throw Exception(appError);
    }
  }

  Future<void> insertFeedback(FeedbackModel feedback) async {
    try {
      await _questsFeedbackTable.insert(
        feedback.toMap(),
      );
    } catch (e) {
      log(e.toString());
      throw Exception(appError);
    }
  }

  // Future<>
}
