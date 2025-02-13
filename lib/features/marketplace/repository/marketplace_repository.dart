import 'dart:developer';

import 'package:questra_app/core/services/sound_effects_service.dart';
import 'package:questra_app/features/analytics/providers/analytics_providers.dart';
import 'package:questra_app/features/inventory/models/inventory_model.dart';
import 'package:questra_app/features/marketplace/models/item_model.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
import 'package:questra_app/imports.dart';

final marketPlaceProvider =
    Provider<MarketplaceRepository>((ref) => MarketplaceRepository(ref: ref));

class MarketplaceRepository {
  final Ref _ref;
  MarketplaceRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _itemsTable => _client.from(TableNames.items);
  SupabaseQueryBuilder get _invTable => _client.from(TableNames.player_owned_items);

  Future<InventoryItem?> getInventoryItemById(String itemId, String userId) async {
    try {
      log("the itemId is $itemId,\n the userId is $userId");
      final data = await _invTable
          .select('''
      *,
      ${TableNames.items}(
      ${KeyNames.item_id},
      ${KeyNames.name},
      ${KeyNames.description},
      ${KeyNames.type},
      ${KeyNames.price},
      ${KeyNames.metadata},
      ${KeyNames.image_url},
      ${KeyNames.created_at},
      ${KeyNames.updated_at}
      )
      ''')
          .eq(
            KeyNames.user_id,
            userId,
          )
          .eq(KeyNames.item_id, itemId);

      final inventory = data
          .map(
            (inv) => InventoryItem.fromMap(inv).copyWith(
              item: ItemModel.fromMap(
                inv[TableNames.items],
              ),
            ),
          )
          .toList();

      if (data.isEmpty) {
        return null;
      }

      return inventory.first;
    } catch (e) {
      log("Exception in get item from inv: ${e.toString()}");
      throw Exception(e);
    }
  }

  Future<List<ItemModel>> getAllItems() async {
    try {
      final data = await _itemsTable.select("*");
      final itemList = data.map((item) => ItemModel.fromMap(item)).toList();
      return itemList;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> buyItem(InventoryItem item) async {
    try {
      log("in buyItem the item id is ${item.itemId}");
      final _user = _ref.read(authStateProvider);
      log("userId: ${_user?.id}");
      int userCoins = _user?.wallet?.balance ?? 0;
      int totalPrice = item.item!.price * item.quantity;

      if (_user == null) {
        throw appError;
      }

      if (userCoins >= totalPrice) {
        final invItem = await getInventoryItemById(item.itemId, _user.id);
        int newQuantity;
        if (invItem == null) {
          newQuantity = item.quantity;
        } else {
          newQuantity = item.quantity + invItem.quantity;
        }

        if (invItem == null) {
          await _invTable.insert(item.toMap());
        } else {
          await _invTable
              .update({
                KeyNames.quantity: newQuantity,
              })
              .eq(KeyNames.user_id, _user.id)
              .eq(
                KeyNames.item_id,
                item.itemId,
              );
        }

        _ref.read(soundEffectsServiceProvider).playEffectWithCache("marketplace_buy.aac");

        _ref
            .read(analyticsServiceProvider)
            .logPurchase(totalPrice.toDouble(), _user.id, item.itemId);
        await _ref.read(walletRepositoryProvider).reduceCoins(userId: _user.id, amount: totalPrice);
      } else {
        throw "You dont have enough coins to by ${item.quantity} ${item.item?.name}";
      }
    } catch (e) {
      log("Exception in buy Item ${e.toString()}");
      if (e.toString().contains(appError)) {
        CustomToast.systemToast(systemMessage: true, appError);
        throw appError;
      }
      rethrow;
    }
  }
}
