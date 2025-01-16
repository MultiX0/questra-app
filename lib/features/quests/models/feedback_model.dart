import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/features/quests/models/quest_model.dart';

class FeedbackModel {
  final int user_feedback_id;
  final DateTime created_at;
  final String user_id;
  final String user_quest_id;
  final String feedback_type;
  final String description;
  final QuestModel? quest;
  FeedbackModel({
    required this.user_feedback_id,
    required this.created_at,
    required this.user_id,
    required this.user_quest_id,
    required this.feedback_type,
    required this.description,
    this.quest,
  });

  FeedbackModel copyWith({
    int? user_feedback_id,
    DateTime? created_at,
    String? user_id,
    String? user_quest_id,
    String? feedback_type,
    QuestModel? quest,
    String? description,
  }) {
    return FeedbackModel(
      user_feedback_id: user_feedback_id ?? this.user_feedback_id,
      created_at: created_at ?? this.created_at,
      user_id: user_id ?? this.user_id,
      user_quest_id: user_quest_id ?? this.user_quest_id,
      feedback_type: feedback_type ?? this.feedback_type,
      description: description ?? this.description,
      quest: quest ?? this.quest,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'user_feedback_id': user_feedback_id,
      // 'created_at': created_at.millisecondsSinceEpoch,
      KeyNames.user_id: user_id,
      KeyNames.user_quest_id: user_quest_id,
      KeyNames.feedback_type: feedback_type,
      KeyNames.description: description,
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      // 'user_feedback_id': user_feedback_id,
      KeyNames.created_at: created_at.toIso8601String(),
      KeyNames.user_id: user_id,
      KeyNames.user_quest_id: user_quest_id,
      KeyNames.feedback_type: feedback_type,
      KeyNames.description: description,
      "quest": quest?.toMap(),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      user_feedback_id: map[KeyNames.user_feedback_id] ?? -1,
      created_at: DateTime.parse(map[KeyNames.created_at] ?? DateTime.now().toIso8601String()),
      user_id: map[KeyNames.user_id] ?? "",
      user_quest_id: map[KeyNames.user_quest_id] ?? -1,
      feedback_type: map[KeyNames.feedback_type] ?? "",
      description: map[KeyNames.description] ?? "",
    );
  }

  @override
  String toString() {
    return 'FeedbackModel(user_feedback_id: $user_feedback_id, created_at: $created_at, user_id: $user_id, user_quest_id: $user_quest_id, feedback_type: $feedback_type, description: $description)';
  }

  @override
  bool operator ==(covariant FeedbackModel other) {
    if (identical(this, other)) return true;

    return other.user_feedback_id == user_feedback_id &&
        other.created_at == created_at &&
        other.user_id == user_id &&
        other.user_quest_id == user_quest_id &&
        other.feedback_type == feedback_type &&
        other.description == description;
  }

  @override
  int get hashCode {
    return user_feedback_id.hashCode ^
        created_at.hashCode ^
        user_id.hashCode ^
        user_quest_id.hashCode ^
        feedback_type.hashCode ^
        description.hashCode;
  }
}
