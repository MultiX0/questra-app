import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:questra_app/core/providers/package_into_provider.dart';
import 'package:questra_app/core/services/package_info_service.dart';
import 'package:questra_app/l10n/l10n.dart';
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
        updateUserOnlineStatus(true);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(KeyNames.user_id, userId);

        handleAppPackage();
      }
    });
    super.initState();
  }

  void handleAppPackage() async {
    ref.read(appVersionProvider.notifier).state = await PackageInfoService.getAppVersion();
    ref.read(appBuildNumberProvider.notifier).state = await PackageInfoService.getAppBuildNumber();
  }

  // final _gameId = dotenv.env["UNITY_GAME_ID"] ?? "";

  Future<void> setAllConsentsToTrue() async {
    await UnityAds.setPrivacyConsent(PrivacyConsentType.gdpr, true);
    await UnityAds.setPrivacyConsent(PrivacyConsentType.ccpa, true);
    await UnityAds.setPrivacyConsent(PrivacyConsentType.pipl, true);
    await UnityAds.setPrivacyConsent(PrivacyConsentType.ageGate, true);
  }

  Future<void> initializeUnityAds() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.none) {
      log('No internet connection');
      return;
    }
    await setAllConsentsToTrue();

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
        CustomToast.systemToast(AppLocalizations.of(context).ad_block_toast, closeDuration: 60);
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
    final currentLocale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    final theme = ref.watch(appThemeProvider);
    return ToastificationWrapper(
      child: MaterialApp.router(
        theme: theme.darkModeAppTheme,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        routerDelegate: router.routerDelegate,
        debugShowCheckedModeBanner: false,
        supportedLocales: L10n.all, // List of supported locales
        locale: currentLocale, // Default language

        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
      ),
    );
  }
}
