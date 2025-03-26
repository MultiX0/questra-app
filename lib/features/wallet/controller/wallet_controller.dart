import 'dart:developer';

import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
import 'package:questra_app/imports.dart';

final walletControllerProvider = StateNotifierProvider<WalletController, bool>(
  (ref) => WalletController(ref: ref),
);

class WalletController extends StateNotifier<bool> {
  final Ref _ref;
  WalletController({required Ref ref}) : _ref = ref, super(false);
  SupabaseClient get _client => _ref.watch(supabaseProvider);
  WalletRepository get _repo => _ref.watch(walletRepositoryProvider);
  bool get isArabic => _ref.watch(localeProvider).languageCode == 'ar';

  Future<void> rewardCoins() async {
    try {
      state = true;
      final userId = _ref.read(authStateProvider)?.id;
      if (userId != null) {
        final rewardLogs = await _client.rpc(
          FunctionNames.get_today_coins_count,
          params: {'p_user_id': userId},
        );

        int count = await _parseData(rewardLogs, userId);

        if (count < 10) {
          final result = await _ref.read(adsServiceProvider.notifier).rewardsAd();
          if (result) {
            await _repo.insertRewardLog(userId);
            await _repo.addCoins(userId: userId, amount: 200);
            CustomToast.systemToast(
              isArabic
                  ? "لقد حصلت على 200 عملة بنجاح."
                  : "You have successfully obtained 200 coins.",
              systemMessage: true,
            );
          } else {
            state = false;
            return;
          }
        }

        throw isArabic
            ? "لديك فرصة لكسب 2000 عملة كحد أقصى يوميًا، بواقع 200 في كل مرة، وقد استنفدت حصتك لهذا اليوم."
            : "You only have the chance to get 2000 coins per day, which is 200 at a time, and you have exhausted today's supply.";
      }

      throw appError;
    } catch (e) {
      state = false;

      log(e.toString());
      CustomToast.systemToast(e.toString());
      rethrow;
    }
  }

  Future<int> _parseData(rewardLogs, String userId) async {
    try {
      if (rewardLogs is int) {
        return rewardLogs;
      } else if (rewardLogs is String) {
        return int.parse(rewardLogs);
      } else {
        await ExceptionService.insertException(
          path: "/wallet_controller",
          error:
              "the data from get_today_coins_count function is not correct and this is the data ($rewardLogs)",
          userId: userId,
        );
        throw appError;
      }
    } catch (e) {
      rethrow;
    }
  }
}
