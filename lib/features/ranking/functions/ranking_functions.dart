import 'package:questra_app/features/ranking/providers/ranking_providers.dart';
import 'package:questra_app/features/ranking/repository/ranking_repository.dart';
import 'package:questra_app/imports.dart';

final rankingFunctionsProvider = Provider<RankingFunctions>((ref) {
  return RankingFunctions(ref: ref);
});

class RankingFunctions {
  final Ref _ref;
  RankingFunctions({required Ref ref}) : _ref = ref;

  Future<void> refreshRanking(String userId) async {
    final currentRanking = await _ref.read(rankingProvider).getPlayerGlobalRank(userId);
    _ref.read(playerRankingProvider.notifier).state = currentRanking;
    _ref.invalidate(playerRankingProvider);
  }
}
