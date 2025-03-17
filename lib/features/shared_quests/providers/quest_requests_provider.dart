// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/imports.dart';

final questRequestsProvider = StateNotifierProvider<QuestRequestsProvider, RequestMiddleWare>(
  (ref) => QuestRequestsProvider(ref: ref),
);

class RequestMiddleWare {
  final Set<RequestModel> requests;
  final bool isLoading;
  RequestMiddleWare({required this.requests, required this.isLoading});

  RequestMiddleWare copyWith({Set<RequestModel>? requests, bool? isLoading}) {
    return RequestMiddleWare(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuestRequestsProvider extends StateNotifier<RequestMiddleWare> {
  final Ref _ref;

  QuestRequestsProvider({required Ref ref})
    : _ref = ref,
      super(RequestMiddleWare(requests: {}, isLoading: true)) {
    getAllRequests();
  }
  SharedQuestsRepository get _repo => _ref.watch(sharedQuestsProvider);

  Future<void> getAllRequests() async {
    try {
      state = state.copyWith(isLoading: true);
      log("requesting for the data...");
      final otherUser = _ref.read(selectedFriendProvider)!;
      final data = await _repo.getAllQuestRequestsFromUser(otherUser.id);
      state = state.copyWith(requests: data.toSet(), isLoading: false);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  void removeRequest(int id) {
    state = state.copyWith(
      requests: state.requests.where((request) => request.requestId != id).toSet(),
    );
  }
}
