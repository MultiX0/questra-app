// import 'dart:convert';
import 'dart:convert';
import 'dart:developer';

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
      List<Map<String, dynamic>> ongoingQuestsData = ongoingQuests.map((quest) {
        return {
          KeyNames.description: quest.description,
          KeyNames.expected_completion_time_date: quest.expected_completion_time_date?.toUtc(),
        };
      }).toList();

      log("currentlly there is ${ongoingQuests.length} quests");
      log("here 4");

      final feedbacks = await _ref.read(questsRepositoryProvider).getUserFeedbacks(userId);
      log("here 5");

      final playerTitles = await _ref.read(profileRepositoryProvider).getUserTitles(userId);
      log("here 6");

      final lastQuests = await _ref.read(questsRepositoryProvider).getLastQuests(userId);

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
                    "previous_titles": "${playerTitles.map((title) => title.title).toList()}",
                    "user_birth_date": "${_user?.birth_date?.toIso8601String()}",
                    "current_time": ${DateTime.now().toIso8601String()},
                    "last_quests": ${lastQuests.map((quest) => quest.toString())},
                    "preferred_quest_types": ${preferredQuestTypes.isEmpty ? [
              'exploration',
              'puzzle'
            ] : preferredQuestTypes.map((type) => type.name).toList()},
                    "goals": ${_user?.goals?.map((goal) => goal.description).toList() ?? []},
                    "last_quests": ${lastUserQuests.map((quest) => quest.toMap()).toList()},
                    "currently_ongoing_quests": ${ongoingQuestsData.map((quest) => quest.toString()).toList()},
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
      await ExceptionService.insertException(
          path: "/ai_functions/generation",
          error: e.toString(),
          userId: Supabase.instance.client.auth.currentUser?.id ?? "null");
      // CustomToast.systemToast(
      //   "there is an error, please try again later",
      // );
      throw Exception(e);
    }
  }

  Future<void> handleQuestResponse(String res, int errors) async {
    try {
      final user = _user!;
      final data = isJson(res);
      if (data != null) {
        String? owned_title = data['player_title'];

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
          created_at: DateTime.now().toUtc(),
          user_id: user.id,
          description: questDescription,
          xp_reward: xp_reward,
          coin_reward: coin_reward,
          difficulty: difficulty,
          status: 'in_progress',
          estimated_completion_time: int.tryParse(estimated_completion_time.toString()) ?? 0,
          title: questTitle,
          expected_completion_time_date:
              DateTime.tryParse(completion_time_date)?.add(const Duration(hours: 12)) ??
                  DateTime.now().add(const Duration(hours: 2)),
          owned_title: owned_title,
          images: [],
          isCustom: false,
        );

        final questId = await _ref.read(questsRepositoryProvider).insertQuest(quest);
        NotificationService().scheduleDailyNotification(
          quest.expected_completion_time_date!.subtract(const Duration(hours: 2)),
          "Quest Reminder",

          "You have less than 2 hours left to complete your quest (${quest.title}), please complete it to avoid penalty.",
          // scheduledTime: quest.expected_completion_time_date!.subtract(const Duration(hours: 2)),
          // scheduledTime:
        );
        List<QuestModel> currentQuests = _ref.read(currentOngointQuestsProvider) ?? [];
        _ref.read(analyticsServiceProvider).logGenerateQuest(user.id);

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

  Future<void> customQuestAnalizer(String questDescription, int errors, String userId) async {
    try {
      if (errors >= 2) {
        throw appError;
      }

      final data = await _ref.read(aiModelObjectProvider).makeAiResponse(
        content: [
          {
            "role": "user",
            "content": "quest description: $questDescription",
          },
          ...userQuestProcessingSystemPrompts,
        ],
      );
      final jsonData = isJson(data);
      if (jsonData != null) {
        String title = jsonData['quest_title'] ?? "";
        String description = jsonData['quest_description'] ?? "";
        String difficulty = jsonData['difficulty'] ?? "";
        int estimated_completion_time = jsonData["estimated_completion_time"] == null
            ? 0
            : int.tryParse(jsonData["estimated_completion_time"].toString()) ?? 0;
        final exception = jsonData["exception"];

        if (exception != null) {
          await _ref.read(questsRepositoryProvider).insertCustomQuestException(
                userId: userId,
                exceptionText: exception.toString(),
              );
          throw exception;
        }

        if (title.isEmpty ||
            description.isEmpty ||
            estimated_completion_time == 0 ||
            difficulty.isEmpty) {
          return customQuestAnalizer(
              "$questDescription (please provide the all fields quest_title && quest_description && difficulty && estimated_completion_time)",
              errors++,
              userId);
        }

        final user = _ref.read(authStateProvider)!;
        final currentLevel = user.level?.level ?? 1;

        int xp_reward = questXp(currentLevel, difficulty);
        int coin_reward = calculateQuestCoins(currentLevel, difficulty);

        if (xp_reward > 800) {
          xp_reward = (xp_reward / 2).toInt();
        }

        if (coin_reward > 300) {
          coin_reward = (coin_reward / 2).toInt();
        }

        QuestModel questModel = QuestModel(
          id: "",
          created_at: DateTime.now(),
          user_id: user.id,
          description: description,
          xp_reward: xp_reward,
          coin_reward: coin_reward,
          difficulty: difficulty,
          status: StatusEnum.in_progress.name,
          estimated_completion_time: estimated_completion_time,
          images: [],
          title: title,
          isCustom: true,
          isActive: true,
        );

        final id = await _ref.read(questsRepositoryProvider).insertQuest(questModel);
        questModel = questModel.copyWith(id: id);

        final currentQuests = _ref.read(customQuestsProvider);
        _ref.invalidate(customQuestsProvider);
        _ref.read(customQuestsProvider.notifier).state = [...currentQuests, questModel];
        CustomToast.systemToast("The quest has been added successfully.", systemMessage: true);
        return;
      }

      throw appError;
    } catch (e) {
      log(e.toString());
      // CustomToast.systemToast(e.toString(), systemMessage: true);
      rethrow;
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
