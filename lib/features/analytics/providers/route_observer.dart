// analytics/route_observer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:questra_app/features/analytics/providers/analytics_providers.dart';

class AnalyticsRouteObserver extends NavigatorObserver {
  final Ref _ref;

  AnalyticsRouteObserver(this._ref);

  @override
  void didPush(Route route, Route? previousRoute) {
    _logScreenView(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _logScreenView(newRoute);
  }

  void _logScreenView(Route route) {
    final routeName = _getRouteName(route);
    if (routeName != null) {
      _ref.read(analyticsServiceProvider).setCurrentScreen(routeName);
    }
  }

  String? _getRouteName(Route route) {
    return route.settings.name;
  }
}

final routeObserverProvider = Provider<AnalyticsRouteObserver>((ref) {
  return AnalyticsRouteObserver(ref);
});
