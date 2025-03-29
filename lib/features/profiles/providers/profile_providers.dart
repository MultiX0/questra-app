import 'package:questra_app/imports.dart';

final userStreakProvider = StateProvider<int>((ref) {
  return 0;
});

final selectedProfileStreak = StateProvider<int>((ref) => 1);
