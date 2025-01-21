// import 'dart:convert';
import 'dart:convert';
import 'dart:developer';

import 'package:questra_app/core/shared/utils/levels_calc.dart';
import 'package:questra_app/features/profiles/repository/profile_repository.dart';
import 'package:questra_app/features/quests/ai/ai_model.dart';
import 'package:questra_app/features/quests/ai/system_parts.dart';
import 'package:questra_app/features/quests/repository/quests_repository.dart';
import 'package:questra_app/imports.dart';

final aiFunctionsProvider = Provider<AiFunctions>((ref) => AiFunctions(ref: ref));

class AiFunctions {
  final Ref _ref;
  AiFunctions({required Ref ref}) : _ref = ref;

  List<Map<String, dynamic>> get systePrompts => questGeneratorSystemPrompts;
  UserModel? get _user => _ref.watch(authStateProvider);

  Future<void> generateQuests({int? errors, String? errorExplain}) async {
    try {
      log("here 1");
      final preferredQuestTypes = await _ref.read(questsRepositoryProvider).getQuestTypesByIds(
            _user?.user_preferences?.questTypes,
          );
      log("here 2");

      String userId = _user?.id ?? "";

      final lastUserQuests = await _ref.read(questsRepositoryProvider).getLastUserQuests(userId);
      log("here 3");

      final ongoingQuests =
          await _ref.read(questsRepositoryProvider).currentlyOngoingQuests(userId);

      log("currentlly there is ${ongoingQuests.length} quests");
      log("here 4");

      final feedbacks = await _ref.read(questsRepositoryProvider).getUserFeedbacks(userId);
      log("here 5");

      final playerTitles = await _ref.read(profileRepositoryProvider).getUserTitles(userId);
      log("here 6");

      String _userPrompt = '''
                {
                  "user_data": {
                    "id": "${_user?.id}",
                    "name": "${_user?.name}",
                    "username": "${_user?.username}",
                    "level": ${_user?.level?.level ?? 1},
                    "difficulty_preferred": "${_user?.user_preferences?.difficulty ?? 'medium'}",
                    "activity_level": "${_user?.user_preferences?.activity_level ?? 'moderate'}",
                    "preferred_times": "${_user?.user_preferences?.preferred_times ?? 'evening'}",
                    "motivation_level": "${_user?.user_preferences?.motivation_level ?? 'high'}",
                    "time_availability": "${_user?.user_preferences?.time_availability ?? '1 hour'}",
                    "social_interactions": "${_user?.user_preferences?.social_interactions ?? 'solo'}",
                    "feedbacks": "${feedbacks.map((feedback) => feedback.toJson()).toList()}",
                    "user_titles": "${playerTitles.map((title) => title.toMap()).toList()}",
                    "user_birth_date": "${_user?.birth_date?.toIso8601String()}",
                    "current_time": ${DateTime.now().toIso8601String()},
                    "preferred_quest_types": ${preferredQuestTypes.isEmpty ? [
              'exploration',
              'puzzle'
            ] : preferredQuestTypes},
                    "goals": ${_user?.goals?.map((goal) => goal.toMap()).toList() ?? []},
                    "last_quests": ${lastUserQuests.map((quest) => quest.toMap()).toList()},
                    "currently_ongoing_quests": ${ongoingQuests.map((quest) => quest.toMap()).toList()},
                  }
                }
                ''';
      final questResponse = await _ref.read(aiModelObjectProvider).makeAiResponse(
        content: [
          {
            "role": "user",
            "content": _userPrompt,
          },
          ...systePrompts,
          if (errorExplain != null)
            {
              "role": "system",
              "content": errorExplain,
            },
        ],
      );
      log(questResponse);
      await handleQuestResponse(questResponse, errors ?? 0);
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(
        "there is an error, please try again later",
      );
      throw Exception(e);
    }
  }

  Future<void> handleQuestResponse(String res, int errors) async {
    try {
      final user = _user!;
      final data = isJson(res);
      if (data != null) {
        String? titleId;
        if (data['player_title'] != null) {
          titleId =
              await _ref.read(profileRepositoryProvider).insertTitle(user.id, data['player_title']);
        }

        final difficulty = data['difficulty'];
        final questTitle = data['quest_title'];
        final questDescription = data['quest_description'];
        final estimated_completion_time = data['estimated_completion_time'];
        final completion_time_date = data['completion_time_date'];

        if (questTitle == null ||
            questDescription == null ||
            difficulty == null ||
            estimated_completion_time == null ||
            completion_time_date == null) {
          generateQuests(
            errors: errors + 1,
            errorExplain:
                "Missing required fields: quest_title, player_title, quest_description, difficulty, estimated_completion_time, completion_time_date. Please regenerate.",
          );
        }

        final currentLevel = user.level?.level ?? 1;
        final xp_reward = questXp(currentLevel, data['difficulty']);
        final coin_reward = calculateQuestCoins(currentLevel, data['difficulty']);

        final QuestModel quest = QuestModel(
          id: "",
          created_at: DateTime.now(),
          user_id: user.id,
          description: questDescription,
          xp_reward: xp_reward,
          coin_reward: coin_reward,
          difficulty: difficulty,
          status: 'in_progress',
          estimated_completion_time: estimated_completion_time,
          title: questTitle,
          expected_completion_time_date: DateTime.tryParse(completion_time_date) ??
              DateTime.now().add(const Duration(hours: 2)),
          owned_title: titleId,
          assigned_at: DateTime.now(),
          images: [],
        );

        final questId = await _ref.read(questsRepositoryProvider).insertQuest(quest);
        List<QuestModel> currentQuests = _ref.read(currentOngointQuestsProvider) ?? [];

        currentQuests = [...currentQuests, quest.copyWith(id: questId)];

        _ref.read(currentOngointQuestsProvider.notifier).state = currentQuests;

        return;
      }

      throw Exception("the data is not json type");
    } catch (e) {
      if (errors >= 1) {
        CustomToast.systemToast(
          "we faceing an error while we making your quests, please try again later!",
          systemMessage: true,
        );
        return;
      }
      generateQuests(errors: errors + 1);
      log(e.toString());
      throw Exception(e);
    }
  }

  Map<String, dynamic>? isJson(String _json) {
    try {
      final data = json.decode(_json);
      return data;
    } catch (e) {
      log("the response is not json");
      return null;
    }
  }
}
