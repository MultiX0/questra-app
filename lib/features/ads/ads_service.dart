import 'dart:async';
import 'dart:developer';

import 'package:questra_app/imports.dart';

final adsServiceProvider = StateNotifierProvider<AdsService, bool>((ref) {
  return AdsService(isArabic: ref.watch(localeProvider).languageCode == 'ar');
});

class AdsService extends StateNotifier<bool> {
  final bool isArabic;
  AdsService({required this.isArabic}) : super(false);

  Future<bool> showAd() async {
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
            log("skipped");
            CustomToast.systemToast(
              isArabic
                  ? "الرجاء مشاهدة الاعلان كاملا بدون تخطيه"
                  : "Please watch the ad until the end",
              systemMessage: true,
            );
            completer.complete(false);
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

    state = false;
    return await completer.future;
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
              log("skipped");
              CustomToast.systemToast(
                isArabic
                    ? "الرجاء مشاهدة الاعلان كاملا بدون تخطيه"
                    : "Please watch the ad until the end",
                systemMessage: true,
              );
              completer.complete(false);
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
