import 'package:questra_app/core/shared/constants/key_names.dart';

class DailyQuestModel {
  final int id;
  final String userId;
  final int pushUps;
  final int setUps;
  final double kmRun;
  final int squats;
  final DateTime createdAt;
  DailyQuestModel({
    required this.id,
    required this.userId,
    required this.pushUps,
    required this.setUps,
    required this.kmRun,
    required this.squats,
    required this.createdAt,
  });

  DailyQuestModel copyWith({
    int? id,
    String? userId,
    int? pushUps,
    int? setUps,
    double? kmRun,
    int? squats,
    DateTime? createdAt,
  }) {
    return DailyQuestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushUps: pushUps ?? this.pushUps,
      setUps: setUps ?? this.setUps,
      kmRun: kmRun ?? this.kmRun,
      squats: squats ?? this.squats,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // KeyNames.id: id,
      KeyNames.user_id: userId,
      KeyNames.data: {
        KeyNames.push_ups: pushUps,
        KeyNames.set_ups: setUps,
        KeyNames.km_run: kmRun,
        KeyNames.squats: squats,
      },
    };
  }

  factory DailyQuestModel.fromMap(Map<String, dynamic> map) {
    return DailyQuestModel(
      id: map[KeyNames.id] ?? -1,
      userId: map[KeyNames.user_id] ?? '',
      pushUps: map[KeyNames.data]?[KeyNames.push_ups] ?? 0,
      setUps: map[KeyNames.data]?[KeyNames.set_ups] ?? 0,
      kmRun: map[KeyNames.data]?[KeyNames.km_run] ?? 0.0,
      squats: map[KeyNames.data]?[KeyNames.squats] ?? 0,
      createdAt: DateTime.parse(map[KeyNames.created_at]),
    );
  }

  @override
  String toString() {
    return 'DailyQuestModel(id: $id, userId: $userId, pushUps: $pushUps, setUps: $setUps, kmRun: $kmRun, kmRun: $squats)';
  }

  @override
  bool operator ==(covariant DailyQuestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.pushUps == pushUps &&
        other.setUps == setUps &&
        other.kmRun == kmRun;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ pushUps.hashCode ^ setUps.hashCode ^ kmRun.hashCode;
  }
}
