import 'package:questra_app/core/shared/constants/key_names.dart';

class PlayerTitleModel {
  final String id;
  final String title;
  final String user_id;
  final DateTime owned_at;
  PlayerTitleModel({
    required this.id,
    required this.title,
    required this.user_id,
    required this.owned_at,
  });

  PlayerTitleModel copyWith({
    String? id,
    String? title,
    String? user_id,
    DateTime? owned_at,
  }) {
    return PlayerTitleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      user_id: user_id ?? this.user_id,
      owned_at: owned_at ?? this.owned_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.title: title,
      KeyNames.user_id: user_id,
      KeyNames.created_at: owned_at.toIso8601String(),
    };
  }

  factory PlayerTitleModel.fromMap(Map<String, dynamic> map) {
    return PlayerTitleModel(
      id: map[KeyNames.id] ?? "",
      title: map[KeyNames.title] ?? "",
      user_id: map[KeyNames.user_id] ?? "",
      owned_at: DateTime.parse(map[KeyNames.created_at]),
    );
  }

  @override
  String toString() {
    return 'PlayerTitleModel(id: $id, title: $title, user_id: $user_id, owned_at: $owned_at)';
  }

  @override
  bool operator ==(covariant PlayerTitleModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.user_id == user_id &&
        other.owned_at == owned_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ user_id.hashCode ^ owned_at.hashCode;
  }
}
