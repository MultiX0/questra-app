import 'dart:developer';
import 'package:questra_app/features/friends/repository/friends_repository.dart';
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
      final data = await _client.rpc(
        FunctionNames.get_player_rank,
        params: {KeyNames.user_id: userId},
      );
      log("ranking data: $data");
      int? rank = data[0]["current_rank"];
      log("user rank is: $rank");
      return rank ?? 0;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<UserModel>> getLeaderboard() async {
    try {
      final data = await _levelsTable
          .select('''
    *,
    players (*)
  ''')
          .order('level', ascending: false)
          .order('xp', ascending: false)
          .limit(100);

      final users =
          data
              .map(
                (level) => UserModel.fromMap(
                  level[TableNames.players],
                ).copyWith(level: LevelsModel.fromMap(level)),
              )
              .toList();

      return users;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<UserModel>> getFriendsRank() async {
    try {
      final me = _ref.read(authStateProvider)!;
      final friends = await _ref
          .read(friendsRepositoryProvider)
          .getAllFriends(userId: me.id, startIndex: 0, pageSize: 1000);
      final friendsIds = friends.map((user) => user.id).toList();
      final data = await _levelsTable
          .select('''
    *,
    players (*)
  ''')
          .inFilter(KeyNames.user_id, [...friendsIds, me.id])
          .order('level', ascending: false)
          .order('xp', ascending: false)
          .limit(100);

      final users =
          data
              .map(
                (level) => UserModel.fromMap(
                  level[TableNames.players],
                ).copyWith(level: LevelsModel.fromMap(level)),
              )
              .toList();

      return users;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
