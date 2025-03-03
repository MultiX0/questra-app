import 'dart:developer';

import 'package:questra_app/core/providers/rewards_providers.dart';
import 'package:questra_app/features/lootbox/lootbox_manager.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
import 'package:questra_app/imports.dart';

final lootBoxControllerProvider = StateNotifierProvider<LootboxController, bool>(
  (ref) => LootboxController(ref: ref),
);

class LootboxController extends StateNotifier<bool> {
  final Ref _ref;
  LootboxController({required Ref ref}) : _ref = ref, super(false);

  LootBoxManager get _manager => LootBoxManager();

  Future<void> reciveReward({required String userId, required int amount}) async {
    try {
      final isArabic = _ref.read(localeProvider).languageCode == 'ar';
      state = true;
      await _ref.read(walletRepositoryProvider).addCoins(userId: userId, amount: amount);
      await _manager.takeLootBox(userId);

      _ref.read(soundEffectsServiceProvider).playEffect("marketplace_buy.aac");
      state = false;
      CustomToast.systemToast(
        isArabic ? "تم حصد الجوائز بنجاح" : "Lootbox has successfully received",
      );
    } catch (e) {
      state = false;

      log(e.toString());
      rethrow;
    }
    _ref.read(hasLootBoxProvider.notifier).state = false;
  }
}
