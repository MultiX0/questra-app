import 'dart:developer';

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

  Future<void> generateQuests() async {
    try {
      final preferredQuestTypes = await _ref.read(questsRepositoryProvider).getQuestTypesByIds(
            _user?.user_preferences?.questTypes,
          );

      final lastUserQuests =
          await _ref.read(questsRepositoryProvider).getLastUserQuests(_user?.id ?? "");

      final ongoingQuests =
          await _ref.read(questsRepositoryProvider).currentlyOngoingQuests(_user?.id ?? "");

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
        ],
      );
      log(questResponse);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> handleQuestResponse() async {
    try {} catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
