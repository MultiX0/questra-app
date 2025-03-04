// ignore_for_file: use_build_context_synchronously

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
  GoalsController({required Ref ref}) : _ref = ref, super(false);

  GoalsRepository get _repo => _ref.watch(goalsRepositoryProvider);
  bool get isArabic => _ref.read(localeProvider).languageCode == 'ar';

  Future<void> insertGoals({required UserGoalModel goal}) async {
    try {
      state = true;
      await _repo.insertGoals(goals: [goal]);

      final goals = _ref.read(playerGoalsProvider);
      _ref.invalidate(playerGoalsProvider);
      _ref.read(playerGoalsProvider).clear();
      _ref.read(playerGoalsProvider).addAll([...goals, goal]);
      CustomToast.systemToast(isArabic ? "تم اضافة هدف جديد بنجاح" : "New goal added successfully");
      state = false;
    } catch (e) {
      log(e.toString());
      state = false;
      throw Exception(e);
    }
  }

  Future<void> deleteGoal(int id, VoidCallback callback) async {
    try {
      state = true;
      UserGoalModel goal = _ref.read(playerGoalsProvider).firstWhere((g) => g.id == id);
      await _repo.deleteGoal(goal);
      final goals = _ref.read(playerGoalsProvider);
      final index = goals.indexWhere((g) => g.id == id);
      _ref.read(playerGoalsProvider).removeAt(index);

      CustomToast.systemToast(
        systemMessage: true,
        isArabic ? "تم حذف الهدف بنجاح." : "goal deleted succesfully",
      );
      callback();

      state = false;
    } catch (e) {
      CustomToast.systemToast(appError);
      state = false;

      log(e.toString());
      rethrow;
    }
  }
}
