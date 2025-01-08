import 'dart:developer';

import 'package:questra_app/core/shared/constants/table_names.dart';
import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) => GoalsRepository(ref: ref));

class GoalsRepository {
  final Ref _ref;
  GoalsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _goalsTable => _client.from(TableNames.user_goals);

  Future<void> insertGoals({required List<UserGoalModel> goals}) async {
    try {
      for (final goal in goals) {
        await _goalsTable.insert(goal.toMap());
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
