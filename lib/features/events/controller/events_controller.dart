// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:questra_app/core/shared/utils/upload_storage.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/events/models/event_model.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/features/events/repository/events_repository.dart';
import 'package:questra_app/imports.dart';

final eventsControllerProvider = StateNotifierProvider<EventsController, bool>(
  (ref) => EventsController(ref: ref),
);

final getQuestEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final controller = ref.watch(eventsControllerProvider.notifier);
  return await controller.getEvents();
});

final getAllQuestsInEventProvider = FutureProvider<List<EventQuestModel>>((ref) async {
  final controller = ref.watch(eventsControllerProvider.notifier);
  final eventId = ref.watch(selectedQuestEvent)!.id;
  return controller.getEventQuests(eventId);
});

class EventsController extends StateNotifier<bool> {
  final Ref _ref;
  EventsController({required Ref ref}) : _ref = ref, super(false);

  EventsRepository get _repo => _ref.watch(eventsRepositoryProvider);

  Future<List<EventModel>> getEvents() async {
    final user = _ref.read(authStateProvider)!;
    return await _repo.getEvents(user);
  }

  Future<List<EventQuestModel>> getEventQuests(int eventId) async {
    try {
      return await _repo.getEventQuests(eventId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> isRegisteredInEvent({required String userId, required int eventId}) async {
    try {
      state = true;
      final res = await _repo.isRegisteredInEvent(userId: userId, eventId: eventId);
      state = false;
      return res;
    } catch (e) {
      state = false;
      CustomToast.systemToast(e.toString(), systemMessage: true);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> registerToEvent({
    required String userId,
    required int eventId,
    required BuildContext context,
  }) async {
    try {
      state = true;
      await _ref.read(adsServiceProvider.notifier).showAd();
      await _repo.registerToEvent(userId: userId, eventId: eventId);
      CustomToast.systemToast("✅ Registration Successful!", systemMessage: true);

      context.pushReplacement(Routes.eventQuestsPage);
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(appError);
    }

    state = false;
  }

  Future<void> finishEventQuest() async {
    try {
      state = true;
      final eventId = _ref.read(selectedQuestEvent)!.id;
      final user = _ref.read(authStateProvider)!;
      final quest = _ref.read(viewEventQuestProvider)!;

      final lastTimeDate = await _repo.getLastCompletetionDate(userId: user.id, questId: quest.id);
      if (lastTimeDate != null) {
        final now = DateTime.now().toUtc();
        final deadLine = lastTimeDate.add(Duration(seconds: quest.break_duration));
        if (now.isBefore(deadLine)) {
          // CustomToast.systemToast("");
          throw 'You need to wait until ${appDateFormat(deadLine.toLocal())}';
        }
      }

      final imageLinks = await _uploadImages(eventId: eventId, questId: quest.id);
      final ids = await _repo.uploadEventPlayerQuestImages(
        images: imageLinks,
        userId: user.id,
        eventId: eventId,
        questId: quest.id,
      );
      await _repo.finishQuest(quest: quest, user: user, imageIds: ids);
      await _ref.read(adsServiceProvider.notifier).showAd();
      state = false;
    } catch (e) {
      log(e.toString());
      state = false;
      CustomToast.systemToast(e.toString());
      rethrow;
    }
  }

  Future<List<String>> _uploadImages({required String questId, required int eventId}) async {
    try {
      final userId = _ref.read(authStateProvider)?.id;
      final _images = _ref.read(questImagesProvider) ?? [];
      List<String> links = [];
      final uuid = Uuid().v4();

      for (final image in _images) {
        final link = await UploadStorage.uploadImages(
          image: image,
          path: "/events/$eventId/$questId/$userId/$uuid/",
        );
        links.add(link);
      }

      return links;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> insertQuestReport({
    required String reporterId,
    required String userId,
    required String questId,
    required String reason,
  }) async {
    try {
      state = true;
      await _repo.insertQuestReport(
        reporterId: reporterId,
        userId: userId,
        questId: questId,
        reason: reason,
      );
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(e.toString());
    }
    state = false;
  }
}
