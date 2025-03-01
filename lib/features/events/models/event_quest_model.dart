import 'package:questra_app/imports.dart';

class EventQuestModel {
  final String id;
  final DateTime created_at;
  final String title;
  final String description;
  final int coin_reward;
  final int xp_reward;
  final int event_id;
  final int break_duration;
  EventQuestModel({
    required this.id,
    required this.created_at,
    required this.title,
    required this.description,
    required this.coin_reward,
    required this.xp_reward,
    required this.event_id,
    required this.break_duration,
  });

  EventQuestModel copyWith({
    String? id,
    DateTime? created_at,
    String? title,
    String? description,
    int? coin_reward,
    int? xp_reward,
    int? event_id,
    int? break_duration,
  }) {
    return EventQuestModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      title: title ?? this.title,
      description: description ?? this.description,
      coin_reward: coin_reward ?? this.coin_reward,
      xp_reward: xp_reward ?? this.xp_reward,
      event_id: event_id ?? this.event_id,
      break_duration: break_duration ?? this.break_duration,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'created_at': created_at.millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'coin_reward': coin_reward,
      'xp_reward': xp_reward,
      'event_id': event_id,
    };
  }

  factory EventQuestModel.fromMap(Map<String, dynamic> map) {
    return EventQuestModel(
      id: map[KeyNames.id] ?? "",
      created_at: DateTime.parse(map[KeyNames.created_at]),
      title: map[KeyNames.title] ?? "",
      description: map[KeyNames.description] ?? "",
      coin_reward: map[KeyNames.coin_reward] ?? 0,
      xp_reward: map[KeyNames.xp_reward] ?? 0,
      event_id: map[KeyNames.event_id] ?? -1,
      break_duration: map[KeyNames.break_duration] ?? 3600,
    );
  }

  @override
  String toString() {
    return 'EventQuestModel(id: $id, created_at: $created_at, title: $title, description: $description, coin_reward: $coin_reward, xp_reward: $xp_reward, event_id: $event_id)';
  }

  @override
  bool operator ==(covariant EventQuestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.created_at == created_at &&
        other.title == title &&
        other.description == description &&
        other.coin_reward == coin_reward &&
        other.xp_reward == xp_reward &&
        other.event_id == event_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        created_at.hashCode ^
        title.hashCode ^
        description.hashCode ^
        coin_reward.hashCode ^
        xp_reward.hashCode ^
        event_id.hashCode;
  }
}
