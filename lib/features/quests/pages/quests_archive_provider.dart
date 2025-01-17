import 'package:questra_app/imports.dart';

final questArchiveProvider = StateNotifierProvider<QuestsArchiveProvider, List<QuestModel>>((ref) {
  return QuestsArchiveProvider(ref: ref);
});

final isArchiveEmptyProvider = StateProvider<bool?>((ref) => null);

class QuestsArchiveProvider extends StateNotifier<List<QuestModel>> {
  final Ref _ref;
  QuestsArchiveProvider({required Ref ref})
      : _ref = ref,
        super([]) {
    init();
  }

  Future<void> init() async {
    final user = _ref.read(authStateProvider);
    final quests =
        await _ref.read(questsControllerProvider.notifier).getQuestsArchive(user?.id ?? "");

    state = List.from(quests);
    if (quests.isEmpty) {
      _ref.read(isArchiveEmptyProvider.notifier).state = true;
    } else {
      _ref.read(isArchiveEmptyProvider.notifier).state = false;
    }
  }

  void addAll(List<QuestModel> quests) {
    state = [...state, ...quests];
    if (state.isNotEmpty) {
      _ref.read(isArchiveEmptyProvider.notifier).state = false;
    } else {
      _ref.read(isArchiveEmptyProvider.notifier).state = true;
    }
  }

  void clear() {
    state = [];
    _ref.read(isArchiveEmptyProvider.notifier).state = true;
  }
}
