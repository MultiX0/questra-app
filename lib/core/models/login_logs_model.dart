import 'package:questra_app/imports.dart';

class LoginLogsModel {
  final int id;
  final String userId;
  final DateTime loggedAt;
  LoginLogsModel({
    required this.id,
    required this.userId,
    required this.loggedAt,
  });

  LoginLogsModel copyWith({
    int? id,
    String? userId,
    DateTime? loggedAt,
  }) {
    return LoginLogsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_id: userId,
      KeyNames.created_at: loggedAt.toIso8601String(),
    };
  }

  factory LoginLogsModel.fromMap(Map<String, dynamic> map) {
    return LoginLogsModel(
      id: map[KeyNames.id] ?? -1,
      userId: map[KeyNames.user_id] ?? "",
      loggedAt: DateTime.parse(map[KeyNames.created_at]),
    );
  }

  @override
  String toString() => 'LoginLogsModel(loggedAt: $loggedAt)';

  @override
  bool operator ==(covariant LoginLogsModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.userId == userId && other.loggedAt == loggedAt;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ loggedAt.hashCode;
}
