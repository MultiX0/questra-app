import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:questra_app/router.dart';

import 'imports.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    initializeUnityAds();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await NotificationsRepository.insertLog(userId);
      }
    });
    super.initState();
  }

  final _gameId = dotenv.env["UNITY_GAME_ID"] ?? "";

  Future<void> initializeUnityAds() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.none) {
      log('No internet connection');
      return;
    }

    UnityAds.init(
      gameId: _gameId,
      testMode: kDebugMode,
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
