import 'dart:developer';

import 'package:questra_app/features/titles/repository/titles_repository.dart';
import 'package:questra_app/imports.dart';

import '../models/player_title_model.dart';

final titlesControllerProvider = StateNotifierProvider<TitlesController, bool>(
  (ref) => TitlesController(ref: ref),
);

final getAllTitlesProvider = FutureProvider.family<List<PlayerTitleModel>, String>((
  ref,
  String userId,
) async {
  final _controller = ref.watch(titlesControllerProvider.notifier);
  return _controller.getAllTitles(userId);
});

class TitlesController extends StateNotifier<bool> {
  final Ref _ref;
  TitlesController({required Ref ref}) : _ref = ref, super(false);
  TitlesRepository get _repo => _ref.watch(titlesRepositoryProvider);
  bool get isArabic => _ref.watch(localeProvider).languageCode == 'ar';

  Future<List<PlayerTitleModel>> getAllTitles(String userId) async {
    try {
      return await _repo.getAllTitles(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleTitleChange({String? id, required String userId}) async {
    try {
      state = true;
      final user = _ref.read(authStateProvider);
      final currentTitle = user!.activeTitleId;
      String? newId = currentTitle == id ? null : id;
      bool changed = currentTitle == id ? false : true;

      await _repo.handleTitleChange(userId: userId, id: newId);
      await Future.delayed(const Duration(milliseconds: 1500));

      state = false;

      CustomToast.systemToast(
        isArabic ? "تمت العملية بنجاح" : "Current Title is ${changed ? "changed" : "deactivate"}",
        systemMessage: true,
      );
    } catch (e) {
      state = false;

      log(e.toString());
      CustomToast.systemToast(appError);
      rethrow;
    }
  }
}
