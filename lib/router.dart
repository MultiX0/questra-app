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
        GoRoute(
          path: Routes.onboardingPage,
          pageBuilder: (context, state) {
            return MaterialPage(
              child: const OnboardingFirstPage(),
            );
          },
        ),
      ],
    );
  },
);
