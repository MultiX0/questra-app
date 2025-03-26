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
      log(quest.id.toString());
      state = state.copyWith(quest: quest);
      final prefs = await SharedPreferences.getInstance();
      final val = jsonEncode(quest.toLocal());
      await prefs.setString('current_daily_quest', val);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> finishQuest(BuildContext context) async {
    try {
      final user = _ref.read(authStateProvider)!;
      await _repo.completeQuest(state.quest!);
      final xp = questXp(user.level!.level, "medium");
      final coins = calculateQuestCoins(user.level!.level, 'easy');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_daily_quest', '');
      await init();
      _ref.read(soundEffectsServiceProvider).playCongrats();
      // ignore: use_build_context_synchronously
      CustomToast.systemToast(AppLocalizations.of(context).daily_quest_complete_alert(coins, xp));
      // ignore: use_build_context_synchronously
      context.pop();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
