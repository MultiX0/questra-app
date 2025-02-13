// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:questra_app/features/onboarding/pages/setup_account_page.dart';
import 'package:questra_app/features/profiles/repository/profile_repository.dart';
import 'package:questra_app/imports.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, bool>((ref) {
  return ProfileController(ref: ref);
});

class ProfileController extends StateNotifier<bool> {
  final Ref _ref;
  ProfileController({required Ref ref})
      : _ref = ref,
        super(false);

  ProfileRepository get _repo => _ref.watch(profileRepositoryProvider);

  Future<bool> checkTheCode(String code, String uesrId,
      {bool inserted = false, required BuildContext context}) async {
    try {
      state = true;
      _ref.invalidate(localCodeProvider);
      _ref.read(localCodeProvider.notifier).state = code;
      _ref.invalidate(localCodeProvider);
      final val = await _repo.checkTheCode(code, uesrId, inserted: inserted);
      if (val == true) {
        context.go(Routes.setupAccountPage);
      }
      state = false;

      return val;
    } catch (e) {
      state = false;

      log(e.toString());
      CustomToast.systemToast(e.toString(), systemMessage: true);
      throw Exception(e);
    }
  }
}
