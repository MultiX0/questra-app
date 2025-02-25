import 'dart:developer';

import 'package:questra_app/features/wallet/models/wallet_model.dart';
import 'package:questra_app/imports.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) => WalletRepository(ref: ref));

class WalletRepository {
  final Ref _ref;
  WalletRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _walletTable => _client.from(TableNames.wallet);
  SupabaseQueryBuilder get _rewardLogsTable => _client.from(TableNames.coins_reward_logs);

  Future<WalletModel> _insertWallet(String userId) async {
    try {
      final wallet = WalletModel(userId: userId, balance: 0);
      await _walletTable.insert(wallet.toMap());
      return wallet;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<WalletModel> getUserWallet(String userId) async {
    try {
      final data = await _walletTable.select('*').eq(KeyNames.user_id, userId).maybeSingle();
      if (data == null) {
        return await _insertWallet(userId);
      }

      return WalletModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> addCoins({required String userId, required int amount}) async {
    try {
      final userWallet = await getUserWallet(userId);
      final newBalance = userWallet.balance + amount;

      await _walletTable.update({KeyNames.balance: newBalance}).eq(
        KeyNames.user_id,
        userId,
      );
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> reduceCoins({required String userId, required int amount}) async {
    final userWallet = await getUserWallet(userId);
    int newBalance = userWallet.balance - amount;
    if (newBalance < 0) {
      newBalance = 0;
    }

    await _walletTable.update({KeyNames.balance: newBalance}).eq(
      KeyNames.user_id,
      userId,
    );
  }

  Future<void> insertRewardLog(String userId) async {
    try {
      await _rewardLogsTable.insert({
        KeyNames.user_id: userId,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
