import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:questra_app/features/app/pages/home_page.dart';
import 'package:questra_app/features/app/widgets/nav_bar.dart';
import 'package:questra_app/features/auth/repository/auth_repository.dart';
import 'package:questra_app/features/onboarding/pages/first_page.dart';
import 'package:questra_app/features/onboarding/pages/onboarding_controller.dart';
import 'package:questra_app/features/onboarding/pages/setup_account_page.dart';
import 'package:questra_app/features/splash/splash.dart';

import 'imports.dart';

final _key = GlobalKey<NavigatorState>();

// final navigationShellProvider = Provider<StatefulNavigationShell>((ref) {
//   throw UnimplementedError();
// });

final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: kDebugMode,
      navigatorKey: _key,
      redirect: (context, state) async {
        final isLoggedIn = ref.watch(isLoggedInProvider);
        if (!isLoggedIn) {
          return Routes.onboardingPage;
        }
        return null;
      },
      routes: [
        StatefulShellRoute.indexedStack(
          branches: [
            StatefulShellBranch(
              routes: [
                buildRoute(
                  path: Routes.homePage,
                  child: const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                buildRoute(
                  path: Routes.quests,
                  child: const SizedBox(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                buildRoute(
                  path: Routes.profile,
                  child: const SizedBox(),
                ),
              ],
            ),
          ],
          builder: (state, context, shell) {
            return MyNavBar(
              navigationShell: shell,
            );
          },
        ),
        buildRoute(
          path: Routes.onboardingPage,
          child: const OnboardingFirstPage(),
        ),
        buildRoute(
          path: Routes.onboardingController,
          child: const OnboardingController(),
        ),
        buildRoute(
          path: Routes.setupAccountPage,
          child: const SetupAccountPage(),
        ),
        buildRoute(
          path: Routes.splash,
          child: const SplashPage(),
        ),
      ],
    );
  },
);

GoRoute buildRoute({required String path, required Widget child}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) {
      return MaterialPage(
        child: child,
      );
    },
  );
}
