import 'package:questra_app/imports.dart';

class LootboxModel {
  final String id;
  final String userId;
  final DateTime lastLootBoxTime;
  final int streak;
  final int totalActions;
  final int sessionTime;
  final DateTime createdAt;
  final bool hasTaken;
  LootboxModel({
    required this.id,
    required this.userId,
    required this.lastLootBoxTime,
    required this.streak,
    required this.totalActions,
    required this.sessionTime,
    required this.createdAt,
    required this.hasTaken,
  });

  LootboxModel copyWith({
    String? id,
    String? userId,
    DateTime? lastLootBoxTime,
    int? streak,
    int? totalActions,
    int? sessionTime,
    DateTime? createdAt,
    bool? hasTaken,
  }) {
    return LootboxModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastLootBoxTime: lastLootBoxTime ?? this.lastLootBoxTime,
      streak: streak ?? this.streak,
      totalActions: totalActions ?? this.totalActions,
      sessionTime: sessionTime ?? this.sessionTime,
      createdAt: createdAt ?? this.createdAt,
      hasTaken: hasTaken ?? this.hasTaken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      KeyNames.user_id: userId,
      KeyNames.last_lootbox_time: lastLootBoxTime.toIso8601String(),
      KeyNames.streak: streak,
      KeyNames.total_actions: totalActions,
      KeyNames.session_time: sessionTime,
      KeyNames.hasTaken: hasTaken,
      // 'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory LootboxModel.fromMap(Map<String, dynamic> map) {
    return LootboxModel(
      id: map[KeyNames.id] ?? "",
      userId: map[KeyNames.user_id] ?? "",
      lastLootBoxTime: DateTime.parse(map[KeyNames.last_lootbox_time]),
      streak: map[KeyNames.streak] ?? 0,
      totalActions: map[KeyNames.total_actions] ?? 0,
      sessionTime: map[KeyNames.session_time] ?? 0,
      hasTaken: map[KeyNames.hasTaken] ?? false,
      createdAt: DateTime.parse(map[KeyNames.created_at]),
    );
  }

  @override
  String toString() {
    return 'LootboxModel(id: $id, userId: $userId, lastLootBoxTime: $lastLootBoxTime, streak: $streak, totalActions: $totalActions, sessionTime: $sessionTime, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant LootboxModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.lastLootBoxTime == lastLootBoxTime &&
        other.streak == streak &&
        other.totalActions == totalActions &&
        other.sessionTime == sessionTime &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        lastLootBoxTime.hashCode ^
        streak.hashCode ^
        totalActions.hashCode ^
        sessionTime.hashCode ^
        createdAt.hashCode;
  }
}
