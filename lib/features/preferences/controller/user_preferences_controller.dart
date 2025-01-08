import 'dart:developer';

import 'package:questra_app/features/preferences/models/user_preferences_model.dart';
import 'package:questra_app/features/preferences/repository/user_preferences_repository.dart';
import 'package:questra_app/imports.dart';

final userPreferencesControllerProvider = StateNotifierProvider<UserPreferencesController, bool>(
    (ref) => UserPreferencesController(ref: ref));

class UserPreferencesController extends StateNotifier<bool> {
  final Ref _ref;
  UserPreferencesController({required Ref ref})
      : _ref = ref,
        super(false);

  UserPreferencesRepository get _repository => _ref.watch(userPreferencesRepositoryProvider);

  Future<UserPreferencesModel?> getUserPreferences(String user_id) async {
    try {
      state = true;
      final data = await _repository.getUserPreferences(user_id);
      if (data != null) {
        state = false;
        return data;
      }

      state = false;
      CustomToast.systemToast("there is an error with the system");
      return null;
    } catch (e) {
      state = false;
      log(e.toString());
      rethrow;
    }
  }
}
