import 'package:questra_app/imports.dart';

class NotificationLogModel {
  final int id;
  final String notification;
  final String userId;
  final DateTime? perfect_time_to_send;
  final DateTime? next_perfect_time;
  final bool sent_now;
  NotificationLogModel({
    required this.id,
    required this.notification,
    required this.userId,
    this.perfect_time_to_send,
    this.next_perfect_time,
    required this.sent_now,
  });

  NotificationLogModel copyWith({
    int? id,
    String? notification,
    String? userId,
    DateTime? perfect_time_to_send,
    DateTime? next_perfect_time,
    bool? sent_now,
  }) {
    return NotificationLogModel(
      id: id ?? this.id,
      notification: notification ?? this.notification,
      userId: userId ?? this.userId,
      perfect_time_to_send: perfect_time_to_send ?? this.perfect_time_to_send,
      next_perfect_time: next_perfect_time ?? this.next_perfect_time,
      sent_now: sent_now ?? this.sent_now,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.notification: notification,
      KeyNames.user_id: userId,
      KeyNames.perfect_time_to_send: perfect_time_to_send?.toIso8601String(),
      KeyNames.next_perfect_time: next_perfect_time?.toIso8601String(),
      KeyNames.sent_now: sent_now,
    };
  }

  factory NotificationLogModel.fromMap(Map<String, dynamic> map) {
    return NotificationLogModel(
      id: map[KeyNames.id] ?? -1,
      notification: map[KeyNames.notification] ?? "",
      userId: map[KeyNames.user_id] ?? "",
      perfect_time_to_send: DateTime.parse(map[KeyNames.perfect_time_to_send]),
      next_perfect_time: DateTime.parse(map[KeyNames.next_perfect_time]),
      sent_now: map[KeyNames.sent_now] ?? false,
    );
  }

  @override
  String toString() {
    return 'NotificationLogModel(id: $id, notification: $notification, userId: $userId, perfect_time_to_send: $perfect_time_to_send, next_perfect_time: $next_perfect_time, sent_now: $sent_now)';
  }

  @override
  bool operator ==(covariant NotificationLogModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.notification == notification &&
        other.userId == userId &&
        other.perfect_time_to_send == perfect_time_to_send &&
        other.next_perfect_time == next_perfect_time &&
        other.sent_now == sent_now;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        notification.hashCode ^
        userId.hashCode ^
        perfect_time_to_send.hashCode ^
        next_perfect_time.hashCode ^
        sent_now.hashCode;
  }
}
