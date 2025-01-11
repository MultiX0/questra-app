import 'package:questra_app/features/quests/models/quest_model.dart';
import 'package:questra_app/imports.dart';

final currentOngointQuestsProvider = StateProvider<List<QuestModel>?>((ref) => null);
final todayQuestsCountProvider = StateProvider<List<QuestModel>?>((ref) => null);

final viewQuestProvider = StateProvider<QuestModel?>((ref) => null);
