// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/shared_quests/models/shared_quest_model.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/imports.dart';

final sharedQuestsStateProvider =
    StateNotifierProvider<SharedQuestsProvider, SharedQuestsMiddleWare>(
      (ref) => SharedQuestsProvider(ref: ref),
    );

class SharedQuestsMiddleWare {
  final Set<SharedQuestModel> quests;
  final bool isLoading;
  SharedQuestsMiddleWare({required this.quests, required this.isLoading});

  SharedQuestsMiddleWare copyWith({Set<SharedQuestModel>? quests, bool? isLoading}) {
    return SharedQuestsMiddleWare(
      quests: quests ?? this.quests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SharedQuestsProvider extends StateNotifier<SharedQuestsMiddleWare> {
  final Ref _ref;
  SharedQuestsProvider({required Ref ref})
    : _ref = ref,
      super(SharedQuestsMiddleWare(isLoading: false, quests: {})) {
    getQuests();
  }

  SharedQuestsRepository get _repo => _ref.watch(sharedQuestsProvider);
  void _loadingState() {
    state = state.copyWith(isLoading: !state.isLoading);
  }

  Future<void> getQuests() async {
    _loadingState();
    log("request to get quests...");
    final userId = _ref.read(selectedFriendProvider)!.id;
    final me = _ref.read(authStateProvider)!;
    final data = await _repo.getAllSharedRequests(user1Id: me.id, user2Id: userId);
    state = state.copyWith(quests: data.toSet());
    _loadingState();
  }

  void removeQuest(int id) {
    state = state.copyWith(quests: state.quests.where((request) => request.id != id).toSet());
  }

  void addQuest(SharedQuestModel quest) {
    state = state.copyWith(quests: {...state.quests, quest});
  }
}
