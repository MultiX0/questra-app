import 'package:questra_app/app.dart';

import 'imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: const App()));
}
