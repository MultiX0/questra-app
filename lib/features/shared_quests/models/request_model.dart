import 'package:questra_app/imports.dart';

class RequestModel {
  final int requestId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime deadLine;
  RequestModel({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.deadLine,
  });

  RequestModel copyWith({
    int? requestId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? deadLine,
  }) {
    return RequestModel(
      requestId: requestId ?? this.requestId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      deadLine: deadLine ?? this.deadLine,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // KeyNames.id: requestId,
      KeyNames.sender_id: senderId,
      KeyNames.receiver_id: receiverId,
      KeyNames.quest_content: content,
      KeyNames.dead_line: deadLine.toIso8601String(),
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      requestId: map[KeyNames.id] ?? "",
      senderId: map[KeyNames.sender_id] ?? "",
      receiverId: map[KeyNames.receiver_id] ?? "",
      content: map[KeyNames.quest_content] ?? "",
      deadLine: DateTime.parse(map[KeyNames.dead_line]),
    );
  }

  @override
  String toString() {
    return 'RequestModel(requestId: $requestId, senderId: $senderId, receiverId: $receiverId, content: $content, deadLine: $deadLine)';
  }

  @override
  bool operator ==(covariant RequestModel other) {
    if (identical(this, other)) return true;

    return other.requestId == requestId &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.content == content &&
        other.deadLine == deadLine;
  }

  @override
  int get hashCode {
    return requestId.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        content.hashCode ^
        deadLine.hashCode;
  }
}
