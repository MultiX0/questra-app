import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:questra_app/app.dart';
import 'package:questra_app/core/services/secure_storage.dart';
import 'package:questra_app/firebase_options.dart';
import 'package:workmanager/workmanager.dart';

import 'core/services/background_service.dart';
import 'imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // init the databases
  await _supabaseInit();
  _firebaseInit();
  initWorkManager();
  await initNotifications();

  editChromeSystem();
  runApp(ProviderScope(child: const App()));
}

Future<void> initNotifications() async {
  await NotificationService().init();
}

void initWorkManager() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  Workmanager().registerPeriodicTask(
    "questCheckTask",
    "questCheck",
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 10),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 15),
  );
}

final _url = dotenv.env['SUPABASE_URL'] ?? "";
final _key = dotenv.env['SUPABASE_KEY'] ?? "";

Future<void> _supabaseInit() async {
  try {
    final secureStorage = SecureLocalStorage();
    await secureStorage.initialize();

    await Supabase.initialize(
      url: _url,
      anonKey: _key,
      debug: kDebugMode,
      authOptions: FlutterAuthClientOptions(
        localStorage: secureStorage,
        detectSessionInUri: true,
        autoRefreshToken: true,
      ),
    );
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

void editChromeSystem() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.top]);
}

Future<void> _firebaseInit() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}
