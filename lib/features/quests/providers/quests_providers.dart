// import 'package:questra_app/features/quests/models/feedback_model.dart';
import 'dart:io';

import 'package:questra_app/features/events/models/event_model.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/imports.dart';

final currentOngointQuestsProvider = StateProvider<List<QuestModel>?>((ref) => null);
final customQuestsProvider = StateProvider<List<QuestModel>>((ref) => []);

final todayQuestsCountProvider = StateProvider<List<QuestModel>?>((ref) => null);

final questImagesProvider = StateProvider<List<File>?>((ref) => null);

final viewQuestProvider = StateProvider<QuestModel?>((ref) => null);
final selectedQuestEvent = StateProvider<EventModel?>((ref) => null);
final viewEventQuestProvider = StateProvider<EventQuestModel?>((ref) => null);
