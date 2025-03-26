// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/imports.dart';

class SelectedSharedQuestSupport {
  final SharedQuestModel? quest;
  final List<UserModel> completedPlayers;
  SelectedSharedQuestSupport({required this.quest, required this.completedPlayers});

  SelectedSharedQuestSupport copyWith({
    SharedQuestModel? quest,
    List<UserModel>? completedPlayers,
  }) {
    return SelectedSharedQuestSupport(
      quest: quest ?? this.quest,
      completedPlayers: completedPlayers ?? this.completedPlayers,
    );
  }
}

final selectedSharedQuestProvider =
    StateNotifierProvider<SharedQuestNotifier, SelectedSharedQuestSupport?>((ref) {
      return SharedQuestNotifier();
    });

class SharedQuestNotifier extends StateNotifier<SelectedSharedQuestSupport?> {
  SharedQuestNotifier() : super(SelectedSharedQuestSupport(completedPlayers: [], quest: null));

  void updateQuest({required SharedQuestModel quest, List<UserModel>? completedPlayers}) {
    state = SelectedSharedQuestSupport(completedPlayers: completedPlayers ?? [], quest: quest);
  }
}

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
