import 'dart:developer';

import 'package:questra_app/features/inventory/models/inventory_model.dart';
import 'package:questra_app/features/inventory/repository/inventory_repository.dart';
import 'package:questra_app/imports.dart';

final inventoryControllerProvider = StateNotifierProvider<InventoryController, bool>(
  (ref) => InventoryController(ref: ref),
);

final getAllInventoryProvider =
    FutureProvider.family<List<InventoryItem>, String>((ref, userId) async {
  final _controller = ref.watch(inventoryControllerProvider.notifier);
  return await _controller.getInventoryItems(userId);
});

class InventoryController extends StateNotifier<bool> {
  final Ref _ref;
  InventoryController({required Ref ref})
      : _ref = ref,
        super(false);

  InventoryRepository get _repository => _ref.watch(inventoryRepositoryProvider);
  Future<List<InventoryItem>> getInventoryItems(String userId) async {
    try {
      return await _repository.getInventoryItems(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
