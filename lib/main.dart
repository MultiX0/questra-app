import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:questra_app/app.dart';
import 'package:questra_app/firebase_options.dart';

import 'imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // init the databases
  _supabaseInit();
  _firebaseInit();

  editChromeSystem();
  runApp(ProviderScope(child: const App()));
}

final _url = dotenv.env['SUPABASE_URL'] ?? "";
final _key = dotenv.env['SUPABASE_KEY'] ?? "";

Future<void> _supabaseInit() async {
  try {
    await Supabase.initialize(
      url: _url,
      anonKey: _key,
      debug: kDebugMode,
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
