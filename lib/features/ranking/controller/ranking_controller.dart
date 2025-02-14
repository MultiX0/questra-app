import 'dart:developer';

import 'package:questra_app/features/ranking/repository/ranking_repository.dart';
import 'package:questra_app/imports.dart';

final rankingControllerProvider =
    StateNotifierProvider<RankingController, bool>((ref) => RankingController(ref: ref));

final getAllRankingLeaderboardProvider = FutureProvider<List<UserModel>>((ref) async {
  final _controller = ref.watch(rankingControllerProvider.notifier);
  return await _controller.getLeaderboard();
});

class RankingController extends StateNotifier<bool> {
  final Ref _ref;
  RankingController({required Ref ref})
      : _ref = ref,
        super(false);

  RankingRepository get _repo => _ref.watch(rankingProvider);

  Future<List<UserModel>> getLeaderboard() async {
    try {
      return await _repo.getLeaderboard();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
