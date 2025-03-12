import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/features/friends/models/friend_request_model.dart';

class FriendshipModel {
  final String userId1;
  final String userId2;
  final int requestId;
  final DateTime createdAt;
  final FriendRequestModel? requestModel;
  FriendshipModel({
    required this.userId1,
    required this.userId2,
    required this.requestId,
    required this.createdAt,
    this.requestModel,
  });

  FriendshipModel copyWith({
    String? userId1,
    String? userId2,
    int? requestId,
    DateTime? createdAt,
    FriendRequestModel? requestModel,
  }) {
    return FriendshipModel(
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      requestId: requestId ?? this.requestId,
      createdAt: createdAt ?? this.createdAt,
      requestModel: requestModel ?? this.requestModel,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_id1: userId1,
      KeyNames.user_id2: userId2,
      KeyNames.request_id: requestId,
      KeyNames.created_at: createdAt.toIso8601String(),
    };
  }

  factory FriendshipModel.fromMap(Map<String, dynamic> map) {
    return FriendshipModel(
      userId1: map[KeyNames.user_id1] ?? "",
      userId2: map[KeyNames.user_id2] ?? "",
      requestId: map[KeyNames.request_id] ?? -1,
      createdAt: DateTime.parse(map[KeyNames.created_at]),
    );
  }

  @override
  String toString() {
    return 'FriendshipModel(userId1: $userId1, userId2: $userId2, requestId: $requestId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant FriendshipModel other) {
    if (identical(this, other)) return true;

    return other.userId1 == userId1 &&
        other.userId2 == userId2 &&
        other.requestId == requestId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return userId1.hashCode ^ userId2.hashCode ^ requestId.hashCode ^ createdAt.hashCode;
  }
}
