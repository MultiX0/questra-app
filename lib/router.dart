import 'package:questra_app/features/app/pages/home_page.dart';
import 'package:questra_app/features/app/widgets/nav_bar.dart';
import 'package:questra_app/features/onboarding/pages/first_page.dart';

import 'imports.dart';

final _key = GlobalKey<NavigatorState>();

// final navigationShellProvider = Provider<StatefulNavigationShell>((ref) {
//   throw UnimplementedError();
// });

final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: Routes.onboardingPage,
      debugLogDiagnostics: false,
      navigatorKey: _key,
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
