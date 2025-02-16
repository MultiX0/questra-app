import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:questra_app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'imports.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _updateAppStatus(true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeUnityAds();

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(KeyNames.user_id, userId);
        await NotificationsRepository.insertLog(userId);
      }
    });
    super.initState();
  }

  // final _gameId = dotenv.env["UNITY_GAME_ID"] ?? "";

  Future<void> initializeUnityAds() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.none) {
      log('No internet connection');
      return;
    }

    UnityAds.init(
      gameId: "5790259",
      testMode: false,
      onComplete: () {
        log('Unity Ads initialization complete');
      },
      onFailed: (error, message) {
        log('Unity Ads initialization failed:');
        log('Error: $error');
        log('Message: $message');
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateAppStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _updateAppStatus(state == AppLifecycleState.resumed);
  }

  Future<void> _updateAppStatus(bool isForeground) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAppInForeground', isForeground);
  }

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
