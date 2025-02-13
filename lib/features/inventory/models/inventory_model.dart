import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/features/marketplace/models/item_model.dart';

class InventoryItem {
  final String id;
  final String user_id;
  final String itemId;
  final int quantity;
  final bool is_active;
  final DateTime acquired_at;
  final ItemModel? item;
  InventoryItem({
    required this.id,
    required this.user_id,
    required this.itemId,
    required this.quantity,
    required this.is_active,
    required this.acquired_at,
    this.item,
  });

  InventoryItem copyWith({
    String? id,
    String? user_id,
    String? itemId,
    int? quantity,
    bool? is_active,
    DateTime? acquired_at,
    ItemModel? item,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      is_active: is_active ?? this.is_active,
      acquired_at: acquired_at ?? this.acquired_at,
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_id: user_id,
      KeyNames.item_id: itemId,
      KeyNames.quantity: quantity,
      KeyNames.is_active: is_active,
      // 'acquired_at': acquired_at.toIso8601String(),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map[KeyNames.ownership_id] ?? "",
      user_id: map[KeyNames.user_id] ?? "",
      itemId: map[KeyNames.item_id] ?? "",
      quantity: map[KeyNames.quantity] ?? 1,
      is_active: map[KeyNames.is_active] ?? false,
      acquired_at: DateTime.tryParse(map[KeyNames.acquired_at]) ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'InventoryModel(id: $id, user_id: $user_id, itemId: $itemId, quantity: $quantity, is_active: $is_active, acquired_at: $acquired_at)';
  }

  @override
  bool operator ==(covariant InventoryItem other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user_id == user_id &&
        other.itemId == itemId &&
        other.quantity == quantity &&
        other.is_active == is_active &&
        other.acquired_at == acquired_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user_id.hashCode ^
        itemId.hashCode ^
        quantity.hashCode ^
        is_active.hashCode ^
        acquired_at.hashCode;
  }
}
