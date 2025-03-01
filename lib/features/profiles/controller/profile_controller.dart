// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:questra_app/core/enums/religions_enum.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/onboarding/pages/setup_account_page.dart';
import 'package:questra_app/imports.dart';

import '../../../core/shared/utils/upload_storage.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, bool>((ref) {
  return ProfileController(ref: ref);
});

class ProfileController extends StateNotifier<bool> {
  final Ref _ref;
  ProfileController({required Ref ref}) : _ref = ref, super(false);

  ProfileRepository get _repo => _ref.watch(profileRepositoryProvider);

  Future<bool> checkTheCode(
    String code,
    String uesrId, {
    bool inserted = false,
    required BuildContext context,
  }) async {
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

  Future<void> updateUserAvatar(File image, String userId, BuildContext context) async {
    try {
      state = true;
      final avatarLink = await _uploadImages(image);
      await _repo.updateAvatar(avatar: avatarLink[0], userId: userId);
      CustomToast.systemToast("your avatar updated successfully");
      await _ref.read(adsServiceProvider.notifier).showAd();

      state = false;
      context.pop();
    } catch (e) {
      state = false;
      log(e.toString());
      CustomToast.systemToast(appError);
      rethrow;
    }
  }

  Future<List<String>> _uploadImages(File image) async {
    try {
      final userId = _ref.read(authStateProvider)?.id;
      final _images = [image];
      List<String> links = [];

      for (final image in _images) {
        final link = await UploadStorage.uploadImages(
          image: image,
          path: "users/$userId/avatar/$userId",
          quiality: 40,
        );
        links.add(link);
      }

      return links;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> defineReligion({required String userId, required Religions? religion}) async {
    try {
      state = true;
      await _repo.defineReligion(userId: userId, religion: religion);
      await Future.delayed(const Duration(milliseconds: 600));
      CustomToast.systemToast("Your religion has been set successfully.", systemMessage: true);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
    state = false;
  }
}
