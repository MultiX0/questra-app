import 'package:questra_app/imports.dart';

class RequestModel {
  final int requestId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime deadLine;
  final bool isAccepted;
  final bool aiGenerated;
  final bool firstCompleteWin;
  RequestModel({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.deadLine,
    required this.aiGenerated,
    required this.firstCompleteWin,
    required this.isAccepted,
  });

  RequestModel copyWith({
    int? requestId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? deadLine,
    bool? isAccepted,
    bool? aiGenerated,
    bool? firstCompleteWin,
  }) {
    return RequestModel(
      requestId: requestId ?? this.requestId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      deadLine: deadLine ?? this.deadLine,
      isAccepted: isAccepted ?? this.isAccepted,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      firstCompleteWin: firstCompleteWin ?? this.firstCompleteWin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // KeyNames.id: requestId,
      KeyNames.sender_id: senderId,
      KeyNames.receiver_id: receiverId,
      KeyNames.quest_content: content,
      KeyNames.dead_line: deadLine.toIso8601String(),
      KeyNames.ai_generated: aiGenerated,
      KeyNames.is_accepted: isAccepted,
      KeyNames.first_complete_win: firstCompleteWin,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      requestId: map[KeyNames.id] ?? "",
      senderId: map[KeyNames.sender_id] ?? "",
      receiverId: map[KeyNames.receiver_id] ?? "",
      content: map[KeyNames.quest_content] ?? "",
      deadLine: DateTime.parse(map[KeyNames.dead_line]),
      aiGenerated: map[KeyNames.ai_generated] ?? false,
      firstCompleteWin: map[KeyNames.first_complete_win] ?? false,
      isAccepted: map[KeyNames.is_accepted] ?? false,
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
