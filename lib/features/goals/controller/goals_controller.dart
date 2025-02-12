import 'dart:developer';

import 'package:questra_app/features/goals/repository/goals_repository.dart';
import 'package:questra_app/imports.dart';

import '../models/user_goal_model.dart';
import '../providers/goals_provider.dart';

final goalsControllerProvider = StateNotifierProvider<GoalsController, bool>((ref) {
  return GoalsController(ref: ref);
});

class GoalsController extends StateNotifier<bool> {
  final Ref _ref;
  GoalsController({required Ref ref})
      : _ref = ref,
        super(false);

  GoalsRepository get _repo => _ref.watch(goalsRepositoryProvider);

  Future<void> insertGoals({required UserGoalModel goal}) async {
    try {
      state = true;
      await _repo.insertGoals(goals: [goal]);

      final goals = _ref.read(playerGoalsProvider);
      _ref.invalidate(playerGoalsProvider);
      _ref.read(playerGoalsProvider.notifier).state = [...goals, goal];
      state = false;
    } catch (e) {
      log(e.toString());
      state = false;
      throw Exception(e);
    }
  }
}
