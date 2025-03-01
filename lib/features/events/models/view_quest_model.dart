// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:questra_app/imports.dart';

class ViewEventQuestModel {
  final String userId;
  final String questId;
  final String questDescription;
  final String questTitle;
  final List<String>? images;
  ViewEventQuestModel({
    required this.userId,
    required this.questId,
    required this.questDescription,
    required this.questTitle,
    this.images,
  });

  ViewEventQuestModel copyWith({
    String? userId,
    String? questId,
    String? questDescription,
    String? questTitle,
    List<String>? images,
  }) {
    return ViewEventQuestModel(
      userId: userId ?? this.userId,
      questId: questId ?? this.questId,
      questDescription: questDescription ?? this.questDescription,
      questTitle: questTitle ?? this.questTitle,
      images: images ?? this.images,
    );
  }

  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'userId': userId,
  //     'questId': questId,
  //     'questDescription': questDescription,
  //     'questTitle': questTitle,
  //     'images': images,
  //   };
  // }

  factory ViewEventQuestModel.fromMap(Map<String, dynamic> map) {
    return ViewEventQuestModel(
      userId: map[KeyNames.user_id] ?? "",
      questId: map[KeyNames.quest_id] ?? "",
      questDescription: map[KeyNames.quest_description] ?? "",
      questTitle: map[KeyNames.quest_title] ?? "",
    );
  }
  @override
  String toString() {
    return 'ViewEventQuestModel(userId: $userId, questId: $questId, questDescription: $questDescription, questTitle: $questTitle, images: $images)';
  }

  @override
  bool operator ==(covariant ViewEventQuestModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.questId == questId &&
        other.questDescription == questDescription &&
        other.questTitle == questTitle &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        questId.hashCode ^
        questDescription.hashCode ^
        questTitle.hashCode ^
        images.hashCode;
  }
}
