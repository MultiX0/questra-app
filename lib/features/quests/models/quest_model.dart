import 'package:questra_app/core/shared/constants/key_names.dart';

class QuestModel {
  final String id;
  final DateTime created_at;
  final String user_id;
  final String title;
  final String description;
  final int xp_reward;
  final int coin_reward;
  final String difficulty;
  final String status;
  final String estimated_completion_time;
  final String? owned_title;
  final DateTime? assigned_at;
  final DateTime? completed_at;
  final DateTime expected_completion_time_date;
  final List images;
  QuestModel({
    required this.id,
    required this.created_at,
    required this.user_id,
    required this.description,
    required this.xp_reward,
    required this.coin_reward,
    required this.difficulty,
    required this.status,
    required this.estimated_completion_time,
    required this.images,
    required this.title,
    this.owned_title,
    this.assigned_at,
    this.completed_at,
    required this.expected_completion_time_date,
  });

  factory QuestModel.newQuest({required QuestModel quest}) {
    return QuestModel(
      id: quest.id,
      created_at: quest.created_at,
      user_id: quest.user_id,
      description: quest.description,
      xp_reward: quest.xp_reward,
      coin_reward: quest.coin_reward,
      difficulty: quest.difficulty,
      status: quest.status,
      estimated_completion_time: quest.estimated_completion_time,
      images: quest.images,
      title: quest.title,
      assigned_at: quest.assigned_at,
      completed_at: quest.completed_at,
      owned_title: quest.owned_title,
      expected_completion_time_date: quest.expected_completion_time_date,
    );
  }

  QuestModel copyWith({
    String? id,
    DateTime? created_at,
    String? user_id,
    String? description,
    int? xp_reward,
    int? coin_reward,
    String? difficulty,
    String? status,
    String? estimated_completion_time,
    DateTime? assigned_at,
    DateTime? completed_at,
    String? owned_title,
    String? title,
    DateTime? expected_completion_time_date,
    List? images,
  }) {
    return QuestModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      user_id: user_id ?? this.user_id,
      description: description ?? this.description,
      xp_reward: xp_reward ?? this.xp_reward,
      coin_reward: coin_reward ?? this.coin_reward,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      estimated_completion_time: estimated_completion_time ?? this.estimated_completion_time,
      assigned_at: assigned_at ?? this.assigned_at,
      completed_at: completed_at ?? this.completed_at,
      title: title ?? this.title,
      expected_completion_time_date:
          expected_completion_time_date ?? this.expected_completion_time_date,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_quest_id: id,
      KeyNames.user_id: user_id,
      KeyNames.quest_title: title,
      KeyNames.quest_description: description,
      KeyNames.xp_reward: xp_reward,
      KeyNames.coin_reward: coin_reward,
      KeyNames.difficulty: difficulty.toLowerCase(),
      KeyNames.status: status.toLowerCase(),
      KeyNames.assigned_at: assigned_at?.toIso8601String(),
      KeyNames.completed_at: completed_at?.toIso8601String(),
      KeyNames.estimated_completion_time: estimated_completion_time,
      KeyNames.owned_title: owned_title,
      KeyNames.expected_completion_time_date: expected_completion_time_date.toIso8601String(),
      KeyNames.images: images,
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map) {
    return QuestModel(
      id: map[KeyNames.user_quest_id] ?? "",
      created_at: DateTime.tryParse(map[KeyNames.created_at]) ?? DateTime.now(),
      user_id: map[KeyNames.user_id] ?? '',
      title: map[KeyNames.quest_title] ?? '',
      description: map[KeyNames.quest_description] ?? "",
      xp_reward: map[KeyNames.xp_reward] ?? 0,
      coin_reward: map[KeyNames.coin_reward] ?? 0,
      difficulty: map[KeyNames.difficulty] ?? '',
      estimated_completion_time: map[KeyNames.estimated_completion_time] ?? "",
      expected_completion_time_date:
          DateTime.tryParse(map[KeyNames.expected_completion_time_date]) ??
              DateTime.now().add(const Duration(hours: 2)),
      status: map[KeyNames.status] ?? "",
      assigned_at:
          map[KeyNames.assigned_at] != null ? DateTime.tryParse(map[KeyNames.assigned_at]) : null,
      completed_at:
          map[KeyNames.completed_at] != null ? DateTime.tryParse(map[KeyNames.completed_at]) : null,
      images: List.from(map[KeyNames.images] ?? []),
    );
  }

  @override
  String toString() {
    return 'QuestModel(id: $id, created_at: $created_at, user_id: $user_id, description: $description, xp_reward: $xp_reward, coin_reward: $coin_reward, difficulty: $difficulty, status: $status, assigned_at: $assigned_at, completed_at: $completed_at)';
  }

  @override
  bool operator ==(covariant QuestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.created_at == created_at &&
        other.user_id == user_id &&
        other.description == description &&
        other.xp_reward == xp_reward &&
        other.coin_reward == coin_reward &&
        other.difficulty == difficulty &&
        other.status == status &&
        other.assigned_at == assigned_at &&
        other.completed_at == completed_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        created_at.hashCode ^
        user_id.hashCode ^
        description.hashCode ^
        xp_reward.hashCode ^
        coin_reward.hashCode ^
        difficulty.hashCode ^
        status.hashCode ^
        assigned_at.hashCode ^
        completed_at.hashCode;
  }
}
