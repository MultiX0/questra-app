import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:questra_app/core/providers/package_into_provider.dart';
import 'package:questra_app/core/services/package_info_service.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:questra_app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/lootbox/lootbox_manager.dart';
import 'imports.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    startSessionTimer();

    WidgetsBinding.instance.addObserver(this);
    _updateAppStatus(true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeUnityAds();

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(KeyNames.user_id, userId);
        handleFCMInsert(userId);
        handleAppPackage();

        await NotificationsRepository.insertLog(userId);
      }
    });
    super.initState();
  }

  void handleAppPackage() async {
    ref.read(appVersionProvider.notifier).state = await PackageInfoService.getAppVersion();
    ref.read(appBuildNumberProvider.notifier).state = await PackageInfoService.getAppBuildNumber();
  }

  void handleFCMInsert(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final prevTimestamp = prefs.getInt("fcm_check");

      if (prevTimestamp != null) {
        final prevDate = DateTime.fromMillisecondsSinceEpoch(prevTimestamp);
        final nextAllowedTime = prevDate.add(const Duration(hours: 2));

        log("Previous check time: $prevDate");
        log("Next allowed check time: $nextAllowedTime");
        log("Current time: $now");

        if (now.isBefore(nextAllowedTime)) {
          log("Skipping FCM check as it's within the 2-hour window.");
          return;
        }
      }

      // Update timestamp
      await prefs.setInt("fcm_check", now.millisecondsSinceEpoch);
      log("FCM check timestamp updated to: $now");

      // Insert FCM token
      await NotificationsRepository.insertFCMToken(userId);
      log("FCM token inserted for user: $userId");
    } catch (e) {
      log("Error in handleFCMInsert: ${e.toString()}");
      rethrow;
    }
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
    stopSessionTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _updateAppStatus(state == AppLifecycleState.resumed);
    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible and running
        startSessionTimer();
        updateUserOnlineStatus(true);

        log("App resumed");
        break;
      case AppLifecycleState.inactive:
        updateUserOnlineStatus(false);

        // App is in an inactive state (e.g., in process of transitioning to foreground/background)
        // May want to start preparing to pause operations
        log("App inactive");
        break;
      case AppLifecycleState.paused:
        updateUserOnlineStatus(false);
        stopSessionTimer();
        // Save session time to Supabase
        _saveSessionTime();
        log("App paused");
        break;
      case AppLifecycleState.detached:
        // App is detached from view hierarchy (typically being killed)
        updateUserOnlineStatus(false);

        stopSessionTimer();
        _saveSessionTime();
        log("App detached");
        break;
      default:
        break;
    }
  }

  void _saveSessionTime() async {
    final lootBoxManager = LootBoxManager();
    await lootBoxManager.saveSessionTime();
  }

  void updateUserOnlineStatus(bool online) {
    ref.read(profileRepositoryProvider).updateOnlineStatus(online);
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
