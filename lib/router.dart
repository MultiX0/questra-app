// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:questra_app/features/app/pages/about_page.dart';
import 'package:questra_app/features/app/pages/home_page.dart';
import 'package:questra_app/features/app/widgets/nav_bar.dart';
import 'package:questra_app/features/app/widgets/upload_avatar_widget.dart';
import 'package:questra_app/features/events/pages/quest_events_page.dart';
import 'package:questra_app/features/events/pages/register_to_event_page.dart';
import 'package:questra_app/features/events/pages/view_event_quest.dart';
import 'package:questra_app/features/goals/pages/player_goals_page.dart';
import 'package:questra_app/features/inventory/pages/inventory_page.dart';
import 'package:questra_app/features/legal/privacy_policy.dart';
import 'package:questra_app/features/legal/terms_of_use.dart';
import 'package:questra_app/features/leveling/pages/leveled_up_page.dart';
import 'package:questra_app/features/marketplace/pages/marketplace_page.dart';
import 'package:questra_app/features/onboarding/pages/first_page.dart';
import 'package:questra_app/features/onboarding/pages/onboarding_controller.dart';
import 'package:questra_app/features/onboarding/pages/setup_account_page.dart';
import 'package:questra_app/features/profiles/pages/player_profile.dart';
import 'package:questra_app/features/quests/pages/add_cusome_quest_page.dart';
import 'package:questra_app/features/quests/pages/custom_quests_page.dart';
import 'package:questra_app/features/quests/pages/quests_page.dart';
import 'package:questra_app/features/quests/pages/view_quest_page.dart';
import 'package:questra_app/features/ranking/pages/leaderboard_page.dart';
import 'package:questra_app/features/splash/splash.dart';
import 'package:questra_app/features/titles/pages/titles_page.dart';

import 'features/analytics/providers/route_observer.dart';
import 'imports.dart';

final _key = GlobalKey<NavigatorState>();

final navigationShellProvider = Provider<StatefulNavigationShell>((ref) {
  throw UnimplementedError();
});

final routerProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(routeObserverProvider);
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: kDebugMode,
    navigatorKey: _key,
    observers: [observer],
    redirect: (context, state) {
      final isLoggedIn = ref.watch(isLoggedInProvider);
      final inOnboardingPage = state.uri.toString() == Routes.onboardingPage;
      final inSplash = state.uri.toString() == Routes.splash;
      final inSetUpPage = state.uri.toString() == Routes.setupAccountPage;
      final haveValidAccount = ref.watch(validAccountProvider);
      final isGoingToLegal =
          state.uri.toString() == Routes.termsPage || state.uri.toString() == Routes.privacyPage;

      if (isGoingToLegal) {
        return null;
      }

      if (inSetUpPage) {
        return null;
      }

      // Only redirect if we're not already in the correct place
      if (inSplash) return null;

      if (isLoggedIn && !haveValidAccount) {
        return Routes.onboardingController;
      }

      if (!isLoggedIn && !haveValidAccount) {
        return Routes.onboardingPage;
      }

      if (inOnboardingPage && isLoggedIn) {
        return Routes.homePage;
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(routes: [buildRoute(path: Routes.homePage, child: const HomePage())]),
          StatefulShellBranch(routes: [buildRoute(path: Routes.quests, child: const QuestsPage())]),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.leaderboardPage, child: LeaderboardPage())],
          ),
          StatefulShellBranch(
            routes: [
              buildRoute(path: Routes.profile, child: PlayerProfile(userId: "", isMe: true)),
            ],
          ),
        ],
        builder: (state, context, shell) {
          return ProviderScope(
            overrides: [navigationShellProvider.overrideWithValue(shell)],
            child: MyNavBar(navigationShell: shell),
          );
        },
      ),
      buildRoute(path: Routes.onboardingPage, child: const OnboardingFirstPage()),
      buildRoute(path: Routes.onboardingController, child: const OnboardingController()),
      buildRoute(path: Routes.setupAccountPage, child: const SetupAccountPage()),
      buildRoute(path: Routes.splash, child: const SplashPage()),
      GoRoute(
        path: Routes.viewQuest,
        name: Routes.viewQuest,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final special = extra[KeyNames.is_custom];
          return MaterialPage(child: ViewQuestPage(special: special));
        },
      ),
      buildRoute(path: Routes.marketPlace, child: const MarketplacePage()),
      GoRoute(
        path: "${Routes.profile}/:${KeyNames.user_id}",
        pageBuilder: (context, state) {
          final userId = state.pathParameters[KeyNames.user_id] ?? "";
          return MaterialPage(child: PlayerProfile(userId: userId));
        },
      ),
      buildRoute(path: Routes.goalsPage, fade: true, child: const PlayerGoalsPage()),
      buildRoute(path: Routes.inventoryPage, fade: true, child: const InventoryPage()),
      buildRoute(path: Routes.privacyPage, fade: true, child: PrivacyPolicy()),
      buildRoute(path: Routes.termsPage, fade: true, child: TermsOfUse()),
      buildRoute(path: Routes.updateAvatarPage, child: UploadAvatarWidget()),
      buildRoute(path: Routes.titlesPage, child: TitlesPage()),
      buildRoute(fade: true, path: Routes.customQuestsPage, child: CustomQuestsPage()),
      buildRoute(path: Routes.addCustomQuestPage, child: AddCusomeQuestPage()),
      buildRoute(fade: true, path: Routes.aboutUsPage, child: AboutPage()),
      buildRoute(fade: true, path: Routes.leveledUpPage, child: LeveledUpPage()),
      buildRoute(fade: true, path: Routes.eventQuestsPage, child: QuestEventsPage()),
      buildRoute(fade: true, path: Routes.registerToEventPage, child: RegisterToEventPage()),
      buildRoute(fade: true, path: Routes.viewEventQuestPage, child: ViewEventQuest()),
    ],
  );
});

GoRoute buildRoute({required String path, required Widget child, bool fade = false}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) {
      if (!fade) {
        return MaterialPage(child: child);
      }

      return CustomTransitionPage(
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    },
  );
}
