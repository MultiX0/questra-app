import 'dart:developer';

import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/core/shared/utils/levels_calc.dart';
import 'package:questra_app/features/inventory/models/inventory_model.dart';
import 'package:questra_app/features/inventory/repository/inventory_repository.dart';
import 'package:questra_app/features/profiles/repository/profile_repository.dart';
import 'package:questra_app/features/titles/repository/titles_repository.dart';
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
        completed_at,
        estimated_completion_time,
        quest_title,
        owned_title,
        expected_completion_time_date,
        images
      )
    ''').eq('user_id', user_id).limit(15).order(KeyNames.created_at, ascending: false);

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
      throw Exception("Feedback function error: $e");
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
          .eq(KeyNames.user_id, user_id)
          .neq(KeyNames.is_custom, true);

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
      // final now = DateTime.now();
      final user = _ref.read(authStateProvider);
      final expectedTimestamp = quest.expected_completion_time_date?.millisecondsSinceEpoch ?? unix;
      final expiryTimestamp = expectedTimestamp + (3 * 60 * 60 * 1000);

      final _quest = await getQuestById(quest.id);
      if (_quest?.status.trim() == StatusEnum.completed.name) {
        throw 'This quest is already completed';
      }

      if (feedback != null) {
        await insertFeedback(feedback);
      }

      // if (now.isBefore(quest.expected_completion_time_date)) {
      //   throw "you need to wait until ${appDateFormat(quest.expected_completion_time_date)}";
      // }

      if (unix > expiryTimestamp) {
        await updateQuestStatus(StatusEnum.failed, quest.id);
        _ref.read(analyticsServiceProvider).logFinishQuest(quest.user_id, StatusEnum.failed.name);
        await failedPunishment(_quest ?? quest);
        throw 'this quest is expired you will receive the penalties';
      }

      final updatedQuest = quest.copyWith(
        status: StatusEnum.completed.name,
        completed_at: DateTime.now(),
      );

      if (quest.owned_title != null && quest.owned_title!.isNotEmpty) {
        final haveTitle = await _ref
            .read(titlesRepositoryProvider)
            .haveTitle(userId: user!.id, title: quest.owned_title!);

        if (!haveTitle) {
          await _ref.read(profileRepositoryProvider).insertTitle(
                user_id: quest.user_id,
                title: quest.owned_title!,
                questId: quest.id,
              );
        }
      }

      _ref.read(analyticsServiceProvider).logFinishQuest(quest.user_id, StatusEnum.completed.name);

      await updateQuest(updatedQuest);

      LevelsModel level = user?.level ?? LevelsModel(user_id: user!.id, level: 1, xp: 0);
      final levelData = addXp(quest.xp_reward, {
        "xp": level.xp,
        "level": level.level,
      });

      level = level.copyWith(xp: levelData['xp'], level: levelData['level']);
      await _updateUserLevel(user!.id, level);
      await _updateUserCoins(user: user, quest: updatedQuest);

      return updatedQuest;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> failedPunishment(QuestModel quest) async {
    try {
      // reduce the user's xp
      // reduce the user's coins by half the quest reward coins amount

      final user = _ref.read(authStateProvider)!;
      final currentLevelModel = user.level ?? LevelsModel(user_id: user.id, level: 1, xp: 0);
      final newLevelModel =
          currentLevelModel.copyWith(xp: (currentLevelModel.xp - (quest.xp_reward / 2).toInt()));
      await _ref.read(levelingRepositoryProvider).updateUserLevelData(newLevelModel);
      await _ref.read(walletRepositoryProvider).reduceCoins(
            userId: user.id,
            amount: (quest.coin_reward / 2).toInt(),
          );
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

  Future<void> updateQuestStatus(StatusEnum status, String questId) async {
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

  Future<int> getSkippedQuestsCount(String userId) async {
    try {
      final data = await _client.rpc(
        FunctionNames.questSkippedCounter,
        params: {
          "p_user_id": userId,
        },
      );

      final count = int.tryParse(data.toString());
      log("the skipped quests count Is: $count");
      return count ?? 0;
    } catch (e) {
      log(e.toString());
      throw Exception('Exception in getSkippedQuestsCount: $e');
    }
  }

  Future<void> handleSkip({
    required QuestModel quest,
    required String userId,
    required FeedbackModel feedback,
  }) async {
    try {
      final skippedCount = await getSkippedQuestsCount(userId);
      final userInv = await _ref.read(inventoryRepositoryProvider).getInventoryItems(userId);
      log(userInv.toString());

      InventoryItem? skipCard = userInv
          .where(
            (item) => item.itemId == skipCardId,
          )
          .firstOrNull;

      log(skipCard.toString());

      if (skipCard == null || skipCard.quantity == 0) {
        if (skippedCount > 3) {
          throw ("you dont have any skip cards to do this action");
        } else {
          _ref
              .read(analyticsServiceProvider)
              .logFinishQuest(quest.user_id, StatusEnum.skipped.name);

          await updateQuestStatus(StatusEnum.skipped, quest.id);
          await insertFeedback(feedback);
        }
        return;
      }

      if (skipCard.quantity >= 1) {
        await updateQuestStatus(StatusEnum.skipped, quest.id);
        _ref.read(analyticsServiceProvider).logFinishQuest(quest.user_id, StatusEnum.skipped.name);

        await _ref.read(inventoryRepositoryProvider).updateInventoryItem(
              itemId: skipCard.itemId,
              userId: userId,
              quantity: skipCard.quantity - 1,
            );
        await insertFeedback(feedback);
        return;
      }

      throw Exception(appError);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<QuestModel>> getFailedQuests(String userId) async {
    try {
      final now = DateTime.now();
      final data = await _playerQuestsTable
          .select("*")
          .eq(KeyNames.user_id, userId)
          .eq(KeyNames.status, StatusEnum.in_progress.name)
          .gte(KeyNames.expected_completion_time_date, now.toIso8601String());

      return data.map((q) => QuestModel.fromMap(q)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<QuestModel>> getLastQuests(String userId) async {
    try {
      final data = await _playerQuestsTable
          .select("*")
          .eq(KeyNames.user_id, userId)
          .order(KeyNames.created_at, ascending: false)
          .limit(8);

      return data.map((quest) => QuestModel.fromMap(quest)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<QuestModel>> getCustomQuests(String userId) async {
    try {
      final data = await _playerQuestsTable.select("*").eq(KeyNames.user_id, userId).eq(
            KeyNames.is_custom,
            true,
          );

      return data.map((quest) => QuestModel.fromMap(quest)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<QuestModel>> getActiveCustomQuests(String userId) async {
    try {
      final data = await _playerQuestsTable
          .select("*")
          .eq(KeyNames.user_id, userId)
          .eq(KeyNames.is_active, true)
          .eq(
            KeyNames.is_custom,
            true,
          );

      return data.map((quest) => QuestModel.fromMap(quest)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deActiveCustomQuest(String userId, String questId) async {
    try {
      await _playerQuestsTable
          .update({
            KeyNames.is_active: false,
          })
          .eq(KeyNames.user_quest_id, questId)
          .eq(KeyNames.user_id, userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
