import 'dart:developer';

import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/features/goals/repository/goals_repository.dart';
import 'package:questra_app/features/preferences/repository/user_preferences_repository.dart';
import 'package:questra_app/features/profiles/models/player_title_model.dart';
import 'package:questra_app/imports.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref: ref);
});

class ProfileRepository {
  final Ref _ref;
  ProfileRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _profilesTable => _client.from(TableNames.players);
  SupabaseQueryBuilder get _userGoalsTable => _client.from(TableNames.user_goals);
  SupabaseQueryBuilder get _datesTable => _client.from(TableNames.users_metadata);
  SupabaseQueryBuilder get _playerTitleTable => _client.from(TableNames.player_titles);

  final uuid = Uuid();

  Future<bool> insertProfile(UserModel user) async {
    try {
      await _profilesTable.insert(user.toMap());
      await Future.wait([
        _ref.read(userPreferencesRepositoryProvider).insertPreferences(user.user_preferences!),
        _ref.read(goalsRepositoryProvider).insertGoals(goals: user.goals!),
        _datesTable.insert(
            {KeyNames.birth_date: user.birth_date?.toIso8601String(), KeyNames.id: user.id}),
      ]);
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<String> getUserBirthDate(String user_id) async {
    try {
      final data =
          await _datesTable.select(KeyNames.birth_date).eq(KeyNames.id, user_id).maybeSingle();
      return data?[KeyNames.birth_date] ??
          DateTime.now().subtract(const Duration(days: 365 * 16)).toIso8601String();
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<List<PlayerTitleModel>> getUserTitles(String user_id) async {
    try {
      final data = await _playerTitleTable.select('*').eq(KeyNames.user_id, user_id);
      final titles = data.map((title) => PlayerTitleModel.fromMap(title)).toList();
      return titles;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<String> insertTitle(String user_id, String title) async {
    try {
      final id = uuid.v4();
      final PlayerTitleModel titleModel = PlayerTitleModel(
        id: id,
        title: title,
        user_id: user_id,
        owned_at: DateTime.now(),
      );

      await _playerTitleTable.insert(titleModel.toMap());

      return id;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

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
}
