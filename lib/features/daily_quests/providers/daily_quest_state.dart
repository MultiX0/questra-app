// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:questra_app/features/daily_quests/models/daily_quest_model.dart';
import 'package:questra_app/features/daily_quests/repository/daily_quests_repository.dart';
import 'package:questra_app/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyQuestHelper {
  final bool isLoading;
  final DailyQuestModel? quest;
  final String? error;
  DailyQuestHelper({required this.isLoading, this.quest, this.error});

  DailyQuestHelper copyWith({bool? isLoading, DailyQuestModel? quest, String? error}) {
    return DailyQuestHelper(
      isLoading: isLoading ?? this.isLoading,
      quest: quest ?? this.quest,
      error: error ?? this.error,
    );
  }
}

final dailyQuestStateProvider = StateNotifierProvider<DailyQuestState, DailyQuestHelper>(
  (ref) => DailyQuestState(ref: ref),
);

class DailyQuestState extends StateNotifier<DailyQuestHelper> {
  final Ref _ref;
  DailyQuestState({required Ref ref}) : _ref = ref, super(DailyQuestHelper(isLoading: true)) {
    init();
  }

  DailyQuestsRepository get _repo => DailyQuestsRepository();

  void handleLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> init() async {
    try {
      final _user = _ref.read(authStateProvider)!;
      handleLoading(true);
      final quest = await _repo.getQuest(_user.id);
      state = state.copyWith(quest: quest);
      handleLoading(false);
    } catch (e) {
      handleLoading(false);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateState(DailyQuestModel quest) async {
    try {
      state = state.copyWith(quest: quest);
      final prefs = await SharedPreferences.getInstance();
      final val = jsonEncode(quest.toLocal());
      await prefs.setString('current_daily_quest', val);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
