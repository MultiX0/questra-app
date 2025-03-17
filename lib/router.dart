// import 'package:flutter/foundation.dart';

import 'package:questra_app/features/shared_quests/controller/shared_quests_middleware.dart';
import 'package:questra_app/features/shared_quests/pages/add_custom_shared_quest_page.dart';
import 'package:questra_app/features/shared_quests/pages/quest_status_page.dart';
import 'package:questra_app/features/shared_quests/pages/requests_page.dart';
import 'package:questra_app/features/shared_quests/pages/shared_quests_page.dart';

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
    debugLogDiagnostics: false,
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
      GoRoute(
        path: "${Routes.playerCompletionPage}/:${KeyNames.user_id}",
        pageBuilder: (context, state) {
          final userId = state.pathParameters[KeyNames.user_id] ?? "";
          return MaterialPage(child: PlayerCompletionPage(userId: userId));
        },
      ),
      buildRoute(fade: true, path: Routes.firendsControllerPage, child: FriendsControllerPage()),
      buildRoute(fade: true, path: Routes.addFriendsPage, child: AddFriendsPage()),
      GoRoute(
        path: "${Routes.player}/:${KeyNames.user_id}",
        pageBuilder: (context, state) {
          final userId = state.pathParameters[KeyNames.user_id] ?? "";
          return MaterialPage(child: OtherProfile(userId: userId));
        },
      ),
      buildRoute(fade: true, path: Routes.addSharedQuestPage, child: AddCustomSharedQuestPage()),
      buildRoute(fade: true, path: Routes.sharedQuestsPage, child: SharedQuestsPage()),
      buildRoute(fade: true, path: Routes.questRequestsPage, child: SharedQuestRequestsPage()),
      buildRoute(fade: true, path: Routes.sharedQuestStatusPage, child: SharedQuestStatusPage()),
      buildRoute(fade: true, path: Routes.sharedQuestViewPage, child: SharedQuestStatusPage()),
      GoRoute(
        path: "${Routes.sharedQuestsMiddleWare}/:${KeyNames.id}",
        pageBuilder: (context, state) {
          int id = int.tryParse(state.pathParameters[KeyNames.id] ?? '-1') ?? -1;
          return MaterialPage(child: SharedQuestsMiddleware(questId: id));
        },
      ),
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
