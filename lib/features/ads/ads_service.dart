import 'dart:async';
import 'dart:developer';

import 'package:questra_app/imports.dart';

final adsServiceProvider = StateNotifierProvider<AdsService, bool>((ref) {
  return AdsService();
});

class AdsService extends StateNotifier<bool> {
  AdsService() : super(false);

  Future<void> showAd() async {
    final Completer<bool> completer = Completer<bool>();

    state = true;
    await UnityAds.load(
      placementId: 'Rewarded_Android',
      onComplete: (placementId) async {
        await UnityAds.showVideoAd(
          placementId: 'Rewarded_Android',
          onStart: (placementId) => log('Video Ad $placementId started'),
          onClick: (placementId) => log('Video Ad $placementId click'),
          onSkipped: (placementId) {
            completer.complete(true);
          },
          onComplete: (placementId) {
            completer.complete(true);
          },
          onFailed: (placementId, error, message) {
            completer.completeError("error: $error, message: $message");
          },
        );
      },
      onFailed: (placementId, error, message) {
        log("$error $message");
      },
    );
    await completer.future;
    state = false;
  }

  Future<bool> rewardsAd() async {
    final Completer<bool> completer = Completer<bool>();
    state = true;

    try {
      await UnityAds.load(
        placementId: 'Rewarded_Android',
        onComplete: (placementId) async {
          await UnityAds.showVideoAd(
            placementId: 'Rewarded_Android',
            onStart: (placementId) => log('Video Ad $placementId started'),
            onClick: (placementId) => log('Video Ad $placementId clicked'),
            onSkipped: (placementId) {
              completer.completeError("You need to finish the ad until the end (without skip)");
            },
            onComplete: (placementId) {
              completer.complete(true);
            },
            onFailed: (placementId, error, message) {
              log('$error $message');
              completer.complete(true);
            },
          );
        },
        onFailed: (placementId, error, message) {
          log("$error $message");
          completer.complete(true);
        },
      );
    } catch (e) {
      // Catch any unexpected errors and reject the completer
      completer.completeError(e);
    }

    // Wait for the completer to resolve
    final result = await completer.future;
    state = false;
    return result;
  }
}
