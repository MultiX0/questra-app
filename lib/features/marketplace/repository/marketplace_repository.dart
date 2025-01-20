import 'dart:developer';

import 'package:questra_app/features/marketplace/models/item_model.dart';
import 'package:questra_app/imports.dart';

final marketPlaceProvider =
    Provider<MarketplaceRepository>((ref) => MarketplaceRepository(ref: ref));

class MarketplaceRepository {
  final Ref _ref;
  MarketplaceRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _itemsTable => _client.from(TableNames.items);

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
}
