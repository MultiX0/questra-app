// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:questra_app/core/shared/utils/upload_storage.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/events/models/event_model.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/features/events/models/view_quest_model.dart';
import 'package:questra_app/features/events/providers/providers.dart';
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

final getPlyaerQuestSubmissionProvider = FutureProvider.family<List<ViewEventQuestModel>, String>((
  ref,
  userId,
) async {
  log("here in getPlyaerQuestSubmissionProvider");
  final controller = ref.watch(eventsControllerProvider.notifier);
  final questId = ref.watch(selectedEventQuestIdProvider)!;
  log("the quest id is: $questId");

  return await controller.getPlayerSubmissions(userId: userId, questId: questId);
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
    required int eventId,
    required BuildContext context,
    required UserModel user,
  }) async {
    try {
      state = true;
      await _ref.read(adsServiceProvider.notifier).showAd();
      if (user.wallet!.balance < calcEventRegisterationFee(user.level?.level ?? 1)) {
        CustomToast.systemToast("You do not have enough coins to register.");
        return;
      }

      await _repo.registerToEvent(userId: user.id, eventId: eventId);
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

  Future<void> insertQuestReport({required String reason, required int finishLogId}) async {
    try {
      state = true;
      final eventId = _ref.read(selectedQuestEvent)!.id;
      final questId = _ref.read(selectedEventQuestIdProvider)!;
      final reporterId = _ref.read(authStateProvider)!.id;
      final userId = _ref.read(selectedEventPlayer)!.id;
      await _repo.insertQuestReport(
        reporterId: reporterId,
        userId: userId,
        questId: questId,
        reason: reason,
        eventId: eventId,
        finishLogId: finishLogId,
      );
      CustomToast.systemToast(
        "Report submitted successfully. Our team will review it soon. Thank you for helping keep Questra fair and fun!",
      );
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(e.toString());
    }
    state = false;
  }

  Future<List<ViewEventQuestModel>> getPlayerSubmissions({
    required String userId,
    required String questId,
  }) async {
    try {
      return await _repo.getPlayerSubmissions(userId: userId, questId: questId);
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(appError);
      rethrow;
    }
  }
}
