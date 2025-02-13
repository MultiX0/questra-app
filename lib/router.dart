// import 'package:flutter/foundation.dart';
import 'package:questra_app/features/app/pages/home_page.dart';
import 'package:questra_app/features/app/widgets/nav_bar.dart';
import 'package:questra_app/features/goals/pages/player_goals_page.dart';
import 'package:questra_app/features/inventory/pages/inventory_page.dart';
import 'package:questra_app/features/marketplace/pages/marketplace_page.dart';
import 'package:questra_app/features/onboarding/pages/first_page.dart';
import 'package:questra_app/features/onboarding/pages/onboarding_controller.dart';
import 'package:questra_app/features/onboarding/pages/setup_account_page.dart';
import 'package:questra_app/features/profiles/pages/player_profile.dart';
import 'package:questra_app/features/quests/pages/quests_page.dart';
import 'package:questra_app/features/quests/pages/view_quest_page.dart';
import 'package:questra_app/features/splash/splash.dart';

import 'imports.dart';

final _key = GlobalKey<NavigatorState>();

final navigationShellProvider = Provider<StatefulNavigationShell>((ref) {
  throw UnimplementedError();
});

final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: false,
      navigatorKey: _key,
      redirect: (context, state) {
        final isLoggedIn = ref.watch(isLoggedInProvider);
        final inOnboardingPage = state.uri.toString() == Routes.onboardingPage;
        if (!isLoggedIn) {
          return Routes.onboardingPage;
        }

        if (inOnboardingPage && isLoggedIn) {
          return Routes.splash;
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
                  child: const QuestsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                buildRoute(
                  path: Routes.profile,
                  child: PlayerProfile(
                    userId: ref.watch(authStateProvider)?.id ?? "",
                  ),
                ),
              ],
            ),
          ],
          builder: (state, context, shell) {
            return ProviderScope(
              overrides: [
                navigationShellProvider.overrideWithValue(shell),
              ],
              child: MyNavBar(
                navigationShell: shell,
              ),
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
        buildRoute(
          path: Routes.viewQuest,
          child: const ViewQuestPage(),
        ),
        buildRoute(
          path: Routes.marketPlace,
          child: const MarketplacePage(),
        ),
        GoRoute(
          path: "${Routes.profile}/:${KeyNames.user_id}",
          pageBuilder: (context, state) {
            final userId = state.pathParameters[KeyNames.user_id] ?? "";
            return MaterialPage(
              child: PlayerProfile(userId: userId),
            );
          },
        ),
        buildRoute(
          path: Routes.goalsPage,
          fade: true,
          child: const PlayerGoalsPage(),
        ),
        buildRoute(
          path: Routes.inventoryPage,
          fade: true,
          child: const InventoryPage(),
        ),
      ],
    );
  },
);

GoRoute buildRoute({
  required String path,
  required Widget child,
  bool fade = false,
}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) {
      if (!fade) {
        return MaterialPage(
          child: child,
        );
      }

      return CustomTransitionPage(
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      );
    },
  );
}
