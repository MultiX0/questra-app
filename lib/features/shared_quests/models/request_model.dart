import 'package:questra_app/core/enums/shared_quest_status_enum.dart';
import 'package:questra_app/imports.dart';

class RequestModel {
  final int requestId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime deadLine;
  final SharedQuestStatusEnum status;
  final bool aiGenerated;
  final bool firstCompleteWin;
  final DateTime sentAt;
  final String arContent;
  RequestModel({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.deadLine,
    required this.aiGenerated,
    required this.firstCompleteWin,
    required this.status,
    required this.sentAt,
    required this.arContent,
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
    SharedQuestStatusEnum? status,
    DateTime? sentAt,
    String? arContent,
  }) {
    return RequestModel(
      requestId: requestId ?? this.requestId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      deadLine: deadLine ?? this.deadLine,
      status: status ?? this.status,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      firstCompleteWin: firstCompleteWin ?? this.firstCompleteWin,
      sentAt: sentAt ?? this.sentAt,
      arContent: arContent ?? this.arContent,
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
      KeyNames.status: sharedQuestStatusToString(status),
      KeyNames.first_complete_win: firstCompleteWin,
      KeyNames.ar_content: arContent,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      requestId: map[KeyNames.id] ?? -1,
      senderId: map[KeyNames.sender_id] ?? "",
      receiverId: map[KeyNames.receiver_id] ?? "",
      content: (map[KeyNames.quest_content] as String?)?.trim() ?? "",
      deadLine: DateTime.parse(map[KeyNames.dead_line]),
      aiGenerated: map[KeyNames.ai_generated] ?? false,
      firstCompleteWin: map[KeyNames.first_complete_win] ?? false,
      status: sharedQuestStatusFromString(map[KeyNames.status]),
      sentAt: DateTime.tryParse(map[KeyNames.created_at]) ?? DateTime.now(),
      arContent: map[KeyNames.ar_content] ?? "",
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
