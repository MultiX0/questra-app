import 'dart:developer';

import 'package:questra_app/core/enums/religions_enum.dart';
import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/features/goals/repository/goals_repository.dart';
import 'package:questra_app/features/preferences/repository/user_preferences_repository.dart';
import 'package:questra_app/features/ranking/providers/ranking_providers.dart';
import 'package:questra_app/features/ranking/repository/ranking_repository.dart';
import 'package:questra_app/features/titles/models/player_title_model.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
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
        _datesTable.insert({
          KeyNames.birth_date: user.birth_date?.toIso8601String(),
          KeyNames.id: user.id,
        }),
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

  Future<String> insertTitle({
    required String user_id,
    required String title,
    required String questId,
  }) async {
    try {
      final id = uuid.v4();
      final PlayerTitleModel titleModel = PlayerTitleModel(
        id: id,
        title: title,
        user_id: user_id,
        owned_at: DateTime.now(),
        quest_id: questId,
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

  Future<PlayerTitleModel?> getActiveTitle(String? titleId) async {
    try {
      if (titleId == null) {
        return null;
      }
      final data = await _playerTitleTable.select("*").eq(KeyNames.id, titleId).maybeSingle();
      return data != null ? PlayerTitleModel.fromMap(data) : null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> checkTheCode(String code, String uesrId, {bool inserted = false}) async {
    try {
      final data = await _client.from('sign_in_codes').select('*').eq('code', code).maybeSingle();
      if (data == null) {
        throw "the code is incorrect";
      }

      if (data['assigned_to'] != null) {
        throw "there is another user toke this code beofre you";
      }

      await _client.from('sign_in_codes').update({'assigned_to': uesrId}).eq('code', code);

      return true;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateAvatar({required String avatar, required String userId}) async {
    try {
      await _profilesTable.update({KeyNames.avatar: avatar}).eq(KeyNames.id, userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final _user = _ref.read(authStateProvider);
      if (_user == null) return;
      await _profilesTable.update({KeyNames.is_online: isOnline}).eq(KeyNames.id, _user.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> defineReligion({required String userId, required Religions? religion}) async {
    try {
      await _profilesTable
          .update({KeyNames.religion: religionToString(religion)})
          .eq(KeyNames.id, userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateAccountLang({required String userId, required String lang}) async {
    try {
      await _profilesTable.update({KeyNames.lang: lang}).eq(KeyNames.id, userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<UserModel>> getUsersIn(List<String> ids) async {
    try {
      final data = await _profilesTable.select("*").inFilter(KeyNames.id, ids);
      return data.map((user) => UserModel.fromMap(user)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> getUserProfileById(String userId) async {
    try {
      final data = await _profilesTable.select("*").eq(KeyNames.id, userId).maybeSingle();
      UserModel _user = UserModel.fromMap(data!);
      final _data = await Future.wait<dynamic>([
        _ref.read(levelingRepositoryProvider).getUserLevel(userId),
        getActiveTitle(userId),
        _ref.read(walletRepositoryProvider).getUserWallet(userId),
        _ref.read(rankingProvider).getPlayerGlobalRank(userId),
      ]);
      final [userLevel, userActiveTitle, userWallet, playerRank] = _data;
      log(
        "=======================================================================================",
      );
      _ref.read(otherPlayerProfileProvider.notifier).state = playerRank;
      log(
        "                                         $playerRank                                       ",
      );

      log(
        "=======================================================================================",
      );

      _user = _user.copyWith(level: userLevel, wallet: userWallet, activeTitle: userActiveTitle);
      return _user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<String> getUserNameById(String id) async {
    try {
      final data = await _profilesTable.select(KeyNames.username).eq(KeyNames.id, id).single();
      return data[KeyNames.username];
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      rethrow;
    }
  }
}
