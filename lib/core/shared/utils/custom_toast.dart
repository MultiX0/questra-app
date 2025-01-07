import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/imports.dart';

class CustomToast {
  static void systemToast(
    String content,
  ) {
    Toastification().show(
      borderSide: BorderSide(
        color: HexColor('43A7D5'),
        width: .75,
      ),
      backgroundColor: Colors.black.withValues(
        alpha: .05,
      ),
      applyBlurEffect: true,
      autoCloseDuration: const Duration(
        seconds: 3,
      ),
      title: Text(content),
      icon: Icon(LucideIcons.hexagon),
    );
  }
}
