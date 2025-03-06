import 'dart:developer';

import 'package:questra_app/imports.dart';
import 'package:rxdart/rxdart.dart';

final levelingRepositoryProvider = Provider<LevelingRepository>(
  (ref) => LevelingRepository(ref: ref),
);

class LevelingRepository {
  final Ref _ref;
  LevelingRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _levelingTable => _client.from(TableNames.player_levels);

  Future<LevelsModel> getUserLevel(String user_id) async {
    try {
      final data = await _levelingTable.select('*').eq(KeyNames.user_id, user_id).maybeSingle();
      if (data == null) {
        return await insertNewLevelRow(user_id);
      }

      return LevelsModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Stream playerLevelStream(String user_id) async* {
    final data = await _levelingTable.select('*').eq(KeyNames.user_id, user_id).maybeSingle();
    if (data == null) {
      await insertNewLevelRow(user_id);
    }

    yield _levelingTable
        .stream(primaryKey: [KeyNames.user_id])
        .eq(KeyNames.user_id, user_id)
        .debounceTime(const Duration(milliseconds: 600))
        .asBroadcastStream();
  }

  Future<LevelsModel?> _getUserLevel(String user_id) async {
    try {
      final data = await _levelingTable.select("*").eq(KeyNames.user_id, user_id).maybeSingle();
      if (data == null) {
        return null;
      }

      return LevelsModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<LevelsModel> insertNewLevelRow(String user_id) async {
    try {
      final _level = await _getUserLevel(user_id);
      if (_level != null) {
        return _level;
      }
      final levelingModel = LevelsModel(user_id: user_id, level: 1, xp: 0);
      await _levelingTable.insert(levelingModel.toMap());
      return levelingModel;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> updateUserLevelData(LevelsModel levelModel) async {
    try {
      final user = _ref.read(authStateProvider);
      log("the user level model that needs to update ${levelModel.toMap()}");
      log("level ${levelModel.level}\nxp:${levelModel.xp}");
      await _levelingTable
          .update({KeyNames.xp: levelModel.xp, KeyNames.level: levelModel.level})
          .eq(KeyNames.user_id, user!.id);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
