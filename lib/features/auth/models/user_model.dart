import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/features/profiles/models/user_goal_model.dart';
import 'package:questra_app/features/profiles/models/user_preferences_model.dart';

class UserModel {
  final String id;
  final DateTime joined_at;
  final String name;
  final String username;
  final bool is_online;
  final String? avatar;
  final List<UserGoalModel>? goals;
  final List<UserPreferencesModel>? user_preferences;
  UserModel({
    required this.id,
    required this.joined_at,
    required this.name,
    required this.username,
    required this.is_online,
    required this.avatar,
    this.goals,
    this.user_preferences,
  });

  UserModel copyWith({
    String? id,
    DateTime? joined_at,
    String? name,
    String? username,
    bool? is_online,
    String? avatar,
    List<UserGoalModel>? goals,
    List<UserPreferencesModel>? user_preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      joined_at: joined_at ?? this.joined_at,
      name: name ?? this.name,
      username: username ?? this.username,
      is_online: is_online ?? this.is_online,
      avatar: avatar ?? this.avatar,
      goals: goals ?? this.goals,
      user_preferences: user_preferences ?? this.user_preferences,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.joined_at: joined_at.millisecondsSinceEpoch,
      KeyNames.name: name,
      KeyNames.username: username,
      KeyNames.is_online: is_online,
      KeyNames.avatar: avatar,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[KeyNames.id] ?? -1,
      joined_at: DateTime.tryParse(map[KeyNames.joined_at]) ?? DateTime.now(),
      name: map[KeyNames.name] ?? "",
      username: map[KeyNames.username] ?? "",
      is_online: map[KeyNames.is_online] ?? false,
      avatar: map[KeyNames.avatar],
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, joined_at: $joined_at, name: $name, username: $username, is_online: $is_online, avatar: $avatar)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.joined_at == joined_at &&
        other.name == name &&
        other.username == username &&
        other.is_online == is_online &&
        other.avatar == avatar;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        joined_at.hashCode ^
        name.hashCode ^
        username.hashCode ^
        is_online.hashCode ^
        avatar.hashCode;
  }
}
