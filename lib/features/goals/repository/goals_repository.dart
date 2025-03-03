import 'dart:developer';

import 'package:questra_app/core/shared/utils/lang_detect.dart';
import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/features/translate/translate_service.dart';
import 'package:questra_app/imports.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) => GoalsRepository(ref: ref));

class GoalsRepository {
  final Ref _ref;
  GoalsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _goalsTable => _client.from(TableNames.user_goals);
  SupabaseQueryBuilder get _deletedGoalsTable => _client.from(TableNames.deleted_goals);
  TranslationService get _translateService => TranslationService();

  Future<List<UserGoalModel>> translateGoals(List<UserGoalModel> goals) async {
    try {
      List<UserGoalModel> _goals = [];
      for (final goal in goals) {
        String? enDescription;
        String? arDescription;
        if (isEnglish(goal.description)) {
          enDescription = goal.description;
          arDescription = await _translateService.translate('en', 'ar', goal.description);
        }
        if (isArabic(goal.description)) {
          arDescription = goal.description;
          enDescription = await _translateService.translate('ar', 'en', goal.description);
        }

        _goals.add(goal.copyWith(description: enDescription, ar_description: arDescription));
      }
      return _goals;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertGoals({required List<UserGoalModel> goals}) async {
    try {
      final _goals = await translateGoals(goals);
      for (final goal in _goals) {
        await _goalsTable.insert(goal.toMap());
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<List<UserGoalModel>> getUserGoals(String user_id) async {
    try {
      final data = await _goalsTable.select('*').eq(KeyNames.user_id, user_id);
      final goals = data.map((goal) => UserGoalModel.fromMap(goal)).toList();
      return goals;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> deleteGoal(UserGoalModel goal) async {
    try {
      await _deletedGoalsTable.insert({
        KeyNames.description: goal.description,
        KeyNames.user_id: goal.user_id,
      });
      await _goalsTable.delete().eq(KeyNames.user_goal_id, goal.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
