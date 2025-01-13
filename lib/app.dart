import 'package:questra_app/router.dart';

import 'imports.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  // @override
  // void initState() {
  //   ref.read(authStateProvider.notifier).logout();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return ToastificationWrapper(
      child: MaterialApp.router(
        theme: AppTheme.darkModeAppTheme,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        routerDelegate: router.routerDelegate,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
