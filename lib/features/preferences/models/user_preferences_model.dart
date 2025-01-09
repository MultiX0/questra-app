import 'package:flutter/foundation.dart';
import 'package:questra_app/core/shared/constants/key_names.dart';

class UserPreferencesModel {
  final int id;
  final String user_id;
  final String difficulty;
  final String? activity_level;
  final List<int>? questTypes;
  final List? preferred_times;
  final String? motivation_level;
  final String? time_availability;
  final String social_interactions;
  UserPreferencesModel({
    required this.id,
    required this.user_id,
    required this.difficulty,
    this.activity_level,
    this.preferred_times,
    this.motivation_level,
    this.time_availability,
    required this.social_interactions,
    this.questTypes,
  });

  UserPreferencesModel copyWith({
    int? id,
    String? user_id,
    String? difficulty,
    String? activity_level,
    List? preferred_times,
    String? motivation_level,
    String? time_availability,
    String? social_interactions,
    List<int>? questTypes,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      difficulty: difficulty ?? this.difficulty,
      activity_level: activity_level ?? this.activity_level,
      preferred_times: preferred_times ?? this.preferred_times,
      motivation_level: motivation_level ?? this.motivation_level,
      time_availability: time_availability ?? this.time_availability,
      social_interactions: social_interactions ?? this.social_interactions,
      questTypes: questTypes ?? this.questTypes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_id: user_id,
      KeyNames.difficulty: difficulty,
      KeyNames.activity_level: activity_level,
      KeyNames.preferred_times: preferred_times,
      KeyNames.motivation_level: motivation_level,
      KeyNames.time_availability: time_availability,
      KeyNames.social_interactions: social_interactions,
      KeyNames.quest_types: questTypes,
    };
  }

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      id: map[KeyNames.user_preference_id] ?? -1,
      user_id: map[KeyNames.user_id] ?? "",
      difficulty: map[KeyNames.difficulty] ?? "",
      activity_level: map[KeyNames.activity_level] ?? "",
      preferred_times: List.from((map[KeyNames.preferred_times] ?? [])),
      motivation_level: map[KeyNames.motivation_level] ?? "",
      time_availability: map[KeyNames.time_availability] ?? "",
      social_interactions: map[KeyNames.social_interactions] ?? "",
      questTypes: List<int>.from(map[KeyNames.quest_types] ?? []),
    );
  }

  @override
  String toString() {
    return 'UserPreferencesModel(id: $id, user_id: $user_id, difficulty: $difficulty, activity_level: $activity_level, preferred_times: $preferred_times, motivation_level: $motivation_level, time_availability: $time_availability, social_interactions: $social_interactions)';
  }

  @override
  bool operator ==(covariant UserPreferencesModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user_id == user_id &&
        other.difficulty == difficulty &&
        other.activity_level == activity_level &&
        listEquals(other.preferred_times, preferred_times) &&
        other.motivation_level == motivation_level &&
        other.time_availability == time_availability &&
        other.social_interactions == social_interactions;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user_id.hashCode ^
        difficulty.hashCode ^
        activity_level.hashCode ^
        preferred_times.hashCode ^
        motivation_level.hashCode ^
        time_availability.hashCode ^
        social_interactions.hashCode;
  }
}
