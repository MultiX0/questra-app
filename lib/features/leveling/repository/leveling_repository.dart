import 'dart:developer';

import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/core/shared/constants/table_names.dart';
import 'package:questra_app/features/leveling/models/levels_model.dart';
import 'package:questra_app/imports.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final levelingRepositoryProvider =
    Provider<LevelingRepository>((ref) => LevelingRepository(ref: ref));

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
        .debounceTime(
          const Duration(milliseconds: 600),
        )
        .asBroadcastStream();
  }

  Future<LevelsModel> insertNewLevelRow(String user_id) async {
    try {
      final levelingModel = LevelsModel(
        user_id: user_id,
        level: 1,
        xp: 0,
      );
      await _levelingTable.insert(levelingModel.toMap());
      return levelingModel;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
