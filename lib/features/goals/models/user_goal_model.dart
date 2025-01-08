import 'package:questra_app/core/shared/constants/key_names.dart';

class UserGoalModel {
  final int id;
  final DateTime created_at;
  final String user_id;
  final String description;
  final DateTime? target_date;
  final String status;
  final DateTime? updated_at;
  UserGoalModel({
    required this.id,
    required this.created_at,
    required this.user_id,
    required this.description,
    this.target_date,
    required this.status,
    this.updated_at,
  });

  UserGoalModel copyWith({
    int? id,
    DateTime? created_at,
    String? user_id,
    String? description,
    DateTime? target_date,
    String? status,
    DateTime? updated_at,
  }) {
    return UserGoalModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      user_id: user_id ?? this.user_id,
      description: description ?? this.description,
      target_date: target_date ?? this.target_date,
      status: status ?? this.status,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.created_at: created_at.toIso8601String(),
      KeyNames.user_id: user_id,
      KeyNames.goal_description: description,
      KeyNames.target_date: target_date?.toIso8601String(),
      KeyNames.status: status,
      KeyNames.updated_at: updated_at,
    };
  }

  factory UserGoalModel.fromMap(Map<String, dynamic> map) {
    return UserGoalModel(
      id: map[KeyNames.user_goal_id] ?? -1,
      created_at: DateTime.tryParse(map[KeyNames.created_at]) ?? DateTime.now(),
      user_id: map[KeyNames.user_id] ?? "",
      description: map[KeyNames.goal_description] ?? "",
      target_date: DateTime.tryParse(map[KeyNames.target_date]),
      status: map[KeyNames.status] ?? "",
      updated_at: DateTime.tryParse(map[KeyNames.updated_at] ?? ""),
    );
  }

  @override
  String toString() {
    return 'UserGoalModel(id: $id, created_at: $created_at, user_id: $user_id, description: $description, target_date: $target_date, status: $status, updated_at: $updated_at)';
  }

  @override
  bool operator ==(covariant UserGoalModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.created_at == created_at &&
        other.user_id == user_id &&
        other.description == description &&
        other.target_date == target_date &&
        other.status == status &&
        other.updated_at == updated_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        created_at.hashCode ^
        user_id.hashCode ^
        description.hashCode ^
        target_date.hashCode ^
        status.hashCode ^
        updated_at.hashCode;
  }
}
