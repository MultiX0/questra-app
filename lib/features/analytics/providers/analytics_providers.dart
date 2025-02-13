import 'package:flutter/foundation.dart';
import 'package:questra_app/imports.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final analytics = ref.watch(firebaseAnalyticsProvider);
  if (kDebugMode) {
    analytics.setAnalyticsCollectionEnabled(false);
  }
  return AnalyticsService(analytics);
});

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    await _analytics.logEvent(
      name: name,
      parameters: params,
    );
  }

  Future<void> setCurrentScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logLogin(String method) async => logEvent('login', {'method': method});
  Future<void> logAccountCreation(String id) async => logEvent('new_account', {'id': id});
  Future<void> logPurchase(double value, String userId, String itemId) async => logEvent(
        'purchase',
        {KeyNames.price: value, KeyNames.user_id: userId, KeyNames.item_id: itemId},
      );

  Future<void> logFinishQuest(String userId, String status) async => logEvent('quest_finish', {
        KeyNames.user_id: userId,
        KeyNames.status: status,
      });

  Future<void> logGenerateQuest(String userId) async => logEvent("quest_generation",
      {KeyNames.user_id: userId, KeyNames.created_at: DateTime.now().toIso8601String()});
}
