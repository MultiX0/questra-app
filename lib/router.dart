import 'package:questra_app/features/app/pages/home_page.dart';
import 'package:questra_app/features/onboarding/pages/first_page.dart';

import 'imports.dart';

final _key = GlobalKey<NavigatorState>();
final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: Routes.onboardingPage,
      debugLogDiagnostics: false,
      navigatorKey: _key,
      routes: [
        buildRoute(
          path: Routes.onboardingPage,
          child: const OnboardingFirstPage(),
        ),
        buildRoute(
          path: Routes.homePage,
          child: const HomePage(),
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
