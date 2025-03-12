import 'package:flutter/foundation.dart';
import 'package:questra_app/imports.dart';

class SharedQuestModel {
  final int id;
  final DateTime createdAt;
  final int requestId;
  final String description;
  final String title;
  final String arDescription;
  final String arTitle;
  final String difficulty;
  final List<dynamic> playersCompleted;
  SharedQuestModel({
    required this.id,
    required this.createdAt,
    required this.requestId,
    required this.description,
    required this.title,
    required this.arDescription,
    required this.arTitle,
    required this.difficulty,
    required this.playersCompleted,
  });

  SharedQuestModel copyWith({
    int? id,
    DateTime? createdAt,
    int? requestId,
    String? description,
    String? title,
    String? arDescription,
    String? arTitle,
    String? difficulty,
    List<dynamic>? playersCompleted,
  }) {
    return SharedQuestModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      requestId: requestId ?? this.requestId,
      description: description ?? this.description,
      title: title ?? this.title,
      arDescription: arDescription ?? this.arDescription,
      arTitle: arTitle ?? this.arTitle,
      difficulty: difficulty ?? this.difficulty,
      playersCompleted: playersCompleted ?? this.playersCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      // 'createdAt': createdAt.millisecondsSinceEpoch,
      KeyNames.request_id: requestId,
      KeyNames.description: description,
      KeyNames.title: title,
      KeyNames.ar_description: arDescription,
      KeyNames.ar_title: arTitle,
      KeyNames.difficulty: difficulty,
      KeyNames.players_completed: playersCompleted,
    };
  }

  factory SharedQuestModel.fromMap(Map<String, dynamic> map) {
    return SharedQuestModel(
      id: map[KeyNames.id] ?? -1,
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      requestId: map[KeyNames.request_id] ?? -1,
      description: map[KeyNames.description] ?? "",
      title: map[KeyNames.title] ?? "",
      arDescription: map[KeyNames.ar_description] ?? "",
      arTitle: map[KeyNames.ar_title] ?? "",
      difficulty: map[KeyNames.difficulty] ?? "hard",
      playersCompleted: List.from(map[KeyNames.players_completed]),
    );
  }

  @override
  String toString() {
    return 'SharedQuestModel(id: $id, createdAt: $createdAt, requestId: $requestId, description: $description, title: $title, arDescription: $arDescription, arTitle: $arTitle, difficulty: $difficulty, playersCompleted: $playersCompleted)';
  }

  @override
  bool operator ==(covariant SharedQuestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.createdAt == createdAt &&
        other.requestId == requestId &&
        other.description == description &&
        other.title == title &&
        other.arDescription == arDescription &&
        other.arTitle == arTitle &&
        other.difficulty == difficulty &&
        listEquals(other.playersCompleted, playersCompleted);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdAt.hashCode ^
        requestId.hashCode ^
        description.hashCode ^
        title.hashCode ^
        arDescription.hashCode ^
        arTitle.hashCode ^
        difficulty.hashCode ^
        playersCompleted.hashCode;
  }
}
