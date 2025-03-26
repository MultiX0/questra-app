import 'package:questra_app/core/shared/constants/key_names.dart';

class DailyQuestModel {
  final int id;
  final String userId;
  final int pushUps;
  final int setUps;
  final double kmRun;
  final int squats;
  final DateTime createdAt;
  final int? pushUpsIdid;
  final int? squatsIdid;
  final int? setUpsIdid;
  final double? runningIdid;
  final DateTime? submittedAt;
  DailyQuestModel({
    required this.id,
    required this.userId,
    required this.pushUps,
    required this.setUps,
    required this.kmRun,
    required this.squats,
    required this.createdAt,
    this.submittedAt,
    this.pushUpsIdid = 0,
    this.runningIdid = 0.0,
    this.setUpsIdid = 0,
    this.squatsIdid = 0,
  });

  DailyQuestModel copyWith({
    int? id,
    String? userId,
    int? pushUps,
    int? setUps,
    double? kmRun,
    int? squats,
    DateTime? createdAt,
    int? pushUpsIdid,
    int? squatsIdid,
    int? setUpsIdid,
    double? runningIdid,
    DateTime? submittedAt,
  }) {
    return DailyQuestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushUps: pushUps ?? this.pushUps,
      setUps: setUps ?? this.setUps,
      kmRun: kmRun ?? this.kmRun,
      squats: squats ?? this.squats,
      createdAt: createdAt ?? this.createdAt,
      pushUpsIdid: pushUpsIdid ?? this.pushUpsIdid,
      squatsIdid: squatsIdid ?? this.squatsIdid,
      setUpsIdid: setUpsIdid ?? this.setUpsIdid,
      runningIdid: runningIdid ?? this.runningIdid,
      submittedAt: submittedAt ?? this.submittedAt,
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

  Map<String, dynamic> toLocal() {
    return <String, dynamic>{
      // KeyNames.id: id,
      KeyNames.user_id: userId,
      if (submittedAt != null) KeyNames.submitted_at: submittedAt!.toIso8601String(),
      KeyNames.data: {
        KeyNames.push_ups: pushUps,
        KeyNames.set_ups: setUps,
        KeyNames.km_run: kmRun,
        KeyNames.squats: squats,

        'pIdid': pushUpsIdid,
        'setIdid': setUpsIdid,
        'sIdid': squatsIdid,
        'rIdid': runningIdid,
      },
      KeyNames.created_at: createdAt.toUtc().toIso8601String(),
    };
  }

  factory DailyQuestModel.fromLocal(Map<String, dynamic> map) {
    return DailyQuestModel(
      id: map[KeyNames.id] ?? -1,
      userId: map[KeyNames.user_id] ?? '',
      pushUps: map[KeyNames.data]?[KeyNames.push_ups] ?? 0,
      setUps: map[KeyNames.data]?[KeyNames.set_ups] ?? 0,
      kmRun: map[KeyNames.data]?[KeyNames.km_run] ?? 0.0,
      squats: map[KeyNames.data]?[KeyNames.squats] ?? 0,
      pushUpsIdid: map[KeyNames.data]?['pIdid'] ?? 0,
      runningIdid: map[KeyNames.data]?['rIdid'] ?? 0.0,
      setUpsIdid: map[KeyNames.data]?['setIdid'] ?? 0,
      squatsIdid: map[KeyNames.data]?['sIdid'] ?? 0,
      createdAt: DateTime.tryParse(map[KeyNames.created_at]) ?? DateTime.now(),
      submittedAt:
          map[KeyNames.submitted_at] == null ? null : DateTime.tryParse(map[KeyNames.submitted_at]),
    );
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
