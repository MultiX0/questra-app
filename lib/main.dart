import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:questra_app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  _supabaseInit();
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
