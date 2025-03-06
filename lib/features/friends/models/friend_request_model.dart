import 'package:questra_app/core/enums/friends_status_enum.dart';
import 'package:questra_app/imports.dart';

class FriendRequestModel {
  final int id;
  final String senderId;
  final String receiverId;
  final DateTime requestDate;
  final FriendsStatusEnum status;
  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.requestDate,
    required this.status,
  });

  FriendRequestModel copyWith({
    int? id,
    String? senderId,
    String? receiverId,
    DateTime? requestDate,
    FriendsStatusEnum? status,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // KeyNames.request_id: id,
      KeyNames.sender_id: senderId,
      KeyNames.receiver_id: receiverId,
      // KeyNames.request_date: requestDate.toIso8601String(),
      KeyNames.status: friendsEnumToString(status),
    };
  }

  factory FriendRequestModel.fromMap(Map<String, dynamic> map) {
    return FriendRequestModel(
      id: map[KeyNames.request_id] ?? -1,
      senderId: map[KeyNames.sender_id] ?? "",
      receiverId: map[KeyNames.receiver_id] ?? "",
      requestDate: DateTime.parse(map[KeyNames.request_date]),
      status: friendsEnumStringToEnum(map[KeyNames.status]),
    );
  }

  @override
  String toString() {
    return 'FriendRequestModel(id: $id, senderId: $senderId, receiverId: $receiverId, requestDate: $requestDate, status: $status)';
  }

  @override
  bool operator ==(covariant FriendRequestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.requestDate == requestDate &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        requestDate.hashCode ^
        status.hashCode;
  }
}
