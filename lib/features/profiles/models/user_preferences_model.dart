import 'package:flutter/foundation.dart';
import 'package:questra_app/core/shared/constants/key_names.dart';

class UserPreferencesModel {
  final int id;
  final String user_id;
  final String difficulty;
  final String? activity_level;
  final String learning_style;
  final List? preferred_times;
  final String? motivation_level;
  final String? time_availability;
  final String social_interactions;
  UserPreferencesModel({
    required this.id,
    required this.user_id,
    required this.difficulty,
    this.activity_level,
    required this.learning_style,
    this.preferred_times,
    this.motivation_level,
    this.time_availability,
    required this.social_interactions,
  });

  UserPreferencesModel copyWith({
    int? id,
    String? user_id,
    String? difficulty,
    String? activity_level,
    String? learning_style,
    List? preferred_times,
    String? motivation_level,
    String? time_availability,
    String? social_interactions,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      difficulty: difficulty ?? this.difficulty,
      activity_level: activity_level ?? this.activity_level,
      learning_style: learning_style ?? this.learning_style,
      preferred_times: preferred_times ?? this.preferred_times,
      motivation_level: motivation_level ?? this.motivation_level,
      time_availability: time_availability ?? this.time_availability,
      social_interactions: social_interactions ?? this.social_interactions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_id: user_id,
      KeyNames.difficulty: difficulty,
      KeyNames.activity_level: activity_level,
      KeyNames.learning_style: learning_style,
      KeyNames.preferred_times: preferred_times,
      KeyNames.motivation_level: motivation_level,
      KeyNames.time_availability: time_availability,
      KeyNames.social_interactions: social_interactions,
    };
  }

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      id: map[KeyNames.user_preference_id] ?? -1,
      user_id: map[KeyNames.user_id] ?? "",
      difficulty: map[KeyNames.difficulty] ?? "",
      activity_level: map[KeyNames.activity_level] ?? "",
      learning_style: map[KeyNames.learning_style] ?? '',
      preferred_times: List.from((map[KeyNames.preferred_times] ?? [])),
      motivation_level: map[KeyNames.motivation_level] ?? "",
      time_availability: map[KeyNames.time_availability] ?? "",
      social_interactions: map[KeyNames.social_interactions] ?? "",
    );
  }

  @override
  String toString() {
    return 'UserPreferencesModel(id: $id, user_id: $user_id, difficulty: $difficulty, activity_level: $activity_level, learning_style: $learning_style, preferred_times: $preferred_times, motivation_level: $motivation_level, time_availability: $time_availability, social_interactions: $social_interactions)';
  }

  @override
  bool operator ==(covariant UserPreferencesModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user_id == user_id &&
        other.difficulty == difficulty &&
        other.activity_level == activity_level &&
        other.learning_style == learning_style &&
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
        learning_style.hashCode ^
        preferred_times.hashCode ^
        motivation_level.hashCode ^
        time_availability.hashCode ^
        social_interactions.hashCode;
  }
}
