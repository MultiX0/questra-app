import 'package:questra_app/core/shared/utils/levels_calc.dart';
import 'package:questra_app/imports.dart';

class LevelsModel {
  final String user_id;
  final DateTime? updated_at;
  int level;
  int xp;
  LevelsModel({
    required this.user_id,
    this.updated_at,
    required this.level,
    required this.xp,
  });

  void addXp(int xp) {
    this.xp += xp;

    while (this.xp >= calculateXpForLevel(level)) {
      this.xp -= calculateXpForLevel(level);
      _levelUp();
    }
  }

  void _levelUp() {
    level++;
    CustomToast.systemToast(
      'Congratulations! You leveled up to $level!',
      systemMessage: true,
    );
  }

  LevelsModel copyWith({
    String? user_id,
    DateTime? updated_at,
    int? level,
    int? xp,
  }) {
    return LevelsModel(
      user_id: user_id ?? this.user_id,
      updated_at: updated_at ?? this.updated_at,
      level: level ?? this.level,
      xp: xp ?? this.xp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_id: user_id,
      // KeyNames.updated_at: updated_at.millisecondsSinceEpoch,
      KeyNames.level: level,
      KeyNames.xp: xp,
    };
  }

  factory LevelsModel.fromMap(Map<String, dynamic> map) {
    return LevelsModel(
      user_id: map[KeyNames.user_id] ?? '',
      updated_at:
          map[KeyNames.updated_at] == null ? null : DateTime.tryParse(map[KeyNames.updated_at]),
      level: map[KeyNames.level] ?? 1,
      xp: map[KeyNames.xp] ?? 0,
    );
  }

  @override
  String toString() {
    return 'LevelsModel(user_id: $user_id, updated_at: $updated_at, level: $level, xp: $xp)';
  }

  @override
  bool operator ==(covariant LevelsModel other) {
    if (identical(this, other)) return true;

    return other.user_id == user_id &&
        other.updated_at == updated_at &&
        other.level == level &&
        other.xp == xp;
  }

  @override
  int get hashCode {
    return user_id.hashCode ^ updated_at.hashCode ^ level.hashCode ^ xp.hashCode;
  }
}
