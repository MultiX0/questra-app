import 'dart:developer';

import 'package:questra_app/features/inventory/models/inventory_model.dart';
import 'package:questra_app/features/marketplace/models/item_model.dart';
import 'package:questra_app/imports.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref: ref);
});

class InventoryRepository {
  final Ref _ref;
  InventoryRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _inventoryTable => _client.from(TableNames.player_owned_items);

  Future<List<InventoryItem>> getInventoryItems(String userId) async {
    try {
      final data = await _inventoryTable.select('''
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
      ''').eq(
        KeyNames.user_id,
        userId,
      );

      final inventory = data
          .map(
            (inv) => InventoryItem.fromMap(inv).copyWith(
              item: ItemModel.fromMap(
                inv[TableNames.items],
              ),
            ),
          )
          .toList();

      return inventory;
    } catch (e) {
      log(e.toString());
      throw Exception("Exception at getInventoryItems: $e");
    }
  }

  Future<void> updateInventoryItem(
      {required String itemId, required String userId, required int quantity}) async {
    try {
      int _localQuantity = quantity;
      if (quantity < 0) {
        _localQuantity = 0;
      }
      await _inventoryTable
          .update({
            KeyNames.quantity: _localQuantity,
          })
          .eq(KeyNames.item_id, itemId)
          .eq(KeyNames.user_id, userId);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
