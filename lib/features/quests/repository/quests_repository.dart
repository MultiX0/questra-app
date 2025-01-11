import 'dart:developer';

import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/core/shared/constants/table_names.dart';
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
}
