import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/imports.dart';

final playerGoalsProvider = StateProvider<List<UserGoalModel>>((ref) {
  return [];
});
