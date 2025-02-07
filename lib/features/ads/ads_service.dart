import 'dart:developer';

import 'package:questra_app/imports.dart';

final adsServiceProvider = StateNotifierProvider<AdsService, bool>((ref) {
  return AdsService();
});

class AdsService extends StateNotifier<bool> {
  AdsService() : super(false);

  Future<void> showAd() async {
    try {
      state = true;
      await UnityAds.load(
        placementId: 'Rewarded_Android',
        onComplete: (placementId) async {
          await UnityAds.showVideoAd(
            placementId: 'Rewarded_Android',
            onStart: (placementId) => log('Video Ad $placementId started'),
            onClick: (placementId) => log('Video Ad $placementId click'),
            onSkipped: (placementId) => log('Video Ad $placementId skipped'),
            onComplete: (placementId) {},
            onFailed: (placementId, error, message) => throw Exception("error: $error"),
          );
          state = false;
        },
        onFailed: (placementId, error, message) {
          throw Exception("error: $error");
        },
      );
    } catch (e) {
      state = false;
      log(e.toString());
      rethrow;
    }
  }
}
