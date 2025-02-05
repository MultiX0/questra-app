import 'package:flutter/foundation.dart';
import 'package:questra_app/imports.dart';

class ItemModel {
  final String id;
  final String name;
  final String? description;
  final String type;
  final int price;
  final Map<String, dynamic>? metadata;
  final String? image_url;
  final DateTime? created_at;
  final DateTime? updated_at;
  final bool locked;
  ItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    required this.locked,
    this.metadata,
    this.image_url,
    this.created_at,
    this.updated_at,
  });

  ItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    int? price,
    Map<String, dynamic>? metadata,
    String? image_url,
    DateTime? created_at,
    DateTime? updated_at,
    bool? locked,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      metadata: metadata ?? this.metadata,
      image_url: image_url ?? this.image_url,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      locked: locked ?? this.locked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.name: name,
      KeyNames.description: description,
      KeyNames.type: type,
      KeyNames.price: price,
      KeyNames.metadata: metadata,
      KeyNames.image_url: image_url,
      KeyNames.locked: locked,
      KeyNames.created_at: created_at?.toIso8601String(),
      KeyNames.updated_at: updated_at?.toIso8601String(),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map[KeyNames.id] ?? "",
      name: map[KeyNames.name] ?? "",
      description: map[KeyNames.description] != null ? map[KeyNames.description] ?? "" : null,
      type: ((map[KeyNames.type] ?? "") as String).toLowerCase(),
      price: map[KeyNames.price] ?? 0,
      metadata: map[KeyNames.metadata] != null
          ? Map<String, dynamic>.from((map[KeyNames.metadata] as Map<String, dynamic>))
          : null,
      image_url: map[KeyNames.image_url] != null ? map[KeyNames.image_url] ?? "" : null,
      created_at:
          map[KeyNames.created_at] != null ? DateTime.parse(map[KeyNames.created_at]) : null,
      updated_at:
          map[KeyNames.updated_at] != null ? DateTime.parse(map[KeyNames.updated_at]) : null,
      locked: map[KeyNames.locked] ?? false,
    );
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, name: $name, description: $description, type: $type, price: $price, metadata: $metadata, image_url: $image_url, created_at: $created_at, updated_at: $updated_at, locked: $locked)';
  }

  @override
  bool operator ==(covariant ItemModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.type == type &&
        other.price == price &&
        mapEquals(other.metadata, metadata) &&
        other.image_url == image_url &&
        other.created_at == created_at &&
        other.updated_at == updated_at &&
        other.locked == locked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        type.hashCode ^
        price.hashCode ^
        metadata.hashCode ^
        image_url.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode ^
        locked.hashCode;
  }
}
