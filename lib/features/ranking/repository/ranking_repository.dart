import 'dart:developer';

import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/imports.dart';

final rankingProvider = Provider<RankingRepository>((ref) => RankingRepository(ref: ref));

class RankingRepository {
  final Ref _ref;
  RankingRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _levelsTable => _client.from(TableNames.player_levels);
  // SupabaseQueryBuilder get _playersTable => _client.from(TableNames.players);

  Future<int?> getPlayerGlobalRank(String userId) async {
    try {
      final data = await _client.rpc(FunctionNames.get_player_rank, params: {
        KeyNames.user_id: userId,
      });
      log("ranking data: $data");
      int? rank = data[0]["current_rank"];
      log("user rank is: $rank");
      return rank;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<UserModel>> getLeaderboard() async {
    try {
      final data = await _levelsTable.select('''
    *,
    players (*)
  ''').order('level', ascending: false).order('xp', ascending: false).limit(500);

      final users = data
          .map(
            (level) => UserModel.fromMap(level[TableNames.players]).copyWith(
              level: LevelsModel.fromMap(level),
            ),
          )
          .toList();

      return users;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
