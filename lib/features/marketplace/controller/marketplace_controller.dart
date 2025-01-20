import 'dart:developer';

import 'package:questra_app/features/marketplace/models/item_model.dart';
import 'package:questra_app/features/marketplace/repository/marketplace_repository.dart';
import 'package:questra_app/imports.dart';

final marketPlaceControllerProvider = StateNotifierProvider<MarketplaceController, bool>((ref) {
  return MarketplaceController(ref: ref);
});

final getAllItemsProvider = FutureProvider<List<ItemModel>>((ref) async {
  final _controller = ref.watch(marketPlaceControllerProvider.notifier);
  return await _controller.getAllItems();
});

class MarketplaceController extends StateNotifier<bool> {
  final Ref _ref;
  MarketplaceController({required Ref ref})
      : _ref = ref,
        super(false);

  MarketplaceRepository get _repository => _ref.watch(marketPlaceProvider);

  Future<List<ItemModel>> getAllItems() async {
    try {
      return await _repository.getAllItems();
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(
        "there's an error right now, please try again later",
        systemMessage: true,
      );
      throw Exception(e);
    }
  }
}
