import 'package:questra_app/imports.dart';

class EventModel {
  final int id;
  final String title;
  final String subtitle;
  final DateTime created_at;
  final DateTime start_at;
  final DateTime? end_at;
  final bool religion_based;
  final String? religion;
  final String event_type;
  final String? thumbnail;
  final int minImageUploadCount;
  EventModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.created_at,
    required this.start_at,
    this.end_at,
    required this.religion_based,
    required this.minImageUploadCount,
    this.religion,
    this.thumbnail,
    required this.event_type,
  });

  EventModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    DateTime? created_at,
    DateTime? start_at,
    DateTime? end_at,
    bool? religion_based,
    String? religion,
    String? event_type,
    String? thumbnail,
    int? minImageUploadCount,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      created_at: created_at ?? this.created_at,
      start_at: start_at ?? this.start_at,
      end_at: end_at ?? this.end_at,
      religion_based: religion_based ?? this.religion_based,
      religion: religion ?? this.religion,
      event_type: event_type ?? this.event_type,
      thumbnail: thumbnail ?? this.thumbnail,
      minImageUploadCount: minImageUploadCount ?? this.minImageUploadCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      // 'created_at': created_at.millisecondsSinceEpoch,
      // 'start_at': start_at.toIso8601String(),
      // 'end_at': end_at?.toIso8601String(),
      'religion_based': religion_based,
      'religion': religion,
      'event_type': event_type,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map[KeyNames.id] ?? -1,
      title: map[KeyNames.title] ?? "",
      subtitle: map[KeyNames.description] ?? "",
      created_at: DateTime.parse(map[KeyNames.created_at]),
      start_at: DateTime.parse(map[KeyNames.start_at]),
      end_at: map[KeyNames.end_at] != null ? DateTime.parse(map[KeyNames.end_at]) : null,
      religion_based: map[KeyNames.religion_based] ?? false,
      religion: map[KeyNames.religion] != null ? map[KeyNames.religion] as String : null,
      event_type: map[KeyNames.event_type] ?? 'quests',
      thumbnail: map[KeyNames.thumbnail],
      minImageUploadCount: map[KeyNames.min_upload_image_count] ?? 1,
    );
  }

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, subtitle: $subtitle, created_at: $created_at, start_at: $start_at, end_at: $end_at, religion_based: $religion_based, religion: $religion, event_type: $event_type)';
  }

  @override
  bool operator ==(covariant EventModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.created_at == created_at &&
        other.start_at == start_at &&
        other.end_at == end_at &&
        other.religion_based == religion_based &&
        other.religion == religion &&
        other.event_type == event_type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        created_at.hashCode ^
        start_at.hashCode ^
        end_at.hashCode ^
        religion_based.hashCode ^
        religion.hashCode ^
        event_type.hashCode;
  }
}
