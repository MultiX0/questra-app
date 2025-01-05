import 'dart:developer';

import 'package:questra_app/core/providers/supabase_provider.dart';
import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/core/shared/constants/table_names.dart';
import 'package:questra_app/features/profiles/models/user_goal_model.dart';
import 'package:questra_app/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref: ref);
});

class ProfileRepository {
  final Ref _ref;
  ProfileRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _profilesTable => _client.from(TableNames.players);
  SupabaseQueryBuilder get _userGoalsTable => _client.from(TableNames.user_goals);

  Future<List<UserGoalModel>> getAllUserGoals(String user_id) async {
    try {
      final data = await _userGoalsTable.select('*').eq(KeyNames.user_id, user_id);
      final goalsList = data.map((goal) => UserGoalModel.fromMap(goal)).toList();
      return goalsList;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> insertNewGoal(List<UserGoalModel> goals) async {
    try {
      for (final goals in goals) {
        await _userGoalsTable.insert(goals.toMap());
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
