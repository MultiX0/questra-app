import 'package:questra_app/imports.dart';

class CustomToast {
  static void systemToast(String content, {bool? systemMessage, int? closeDuration}) {
    Toastification().show(
      borderSide: BorderSide(color: HexColor('43A7D5'), width: .75),
      backgroundColor: Colors.black.withValues(alpha: .05),
      applyBlurEffect: true,
      autoCloseDuration: Duration(seconds: closeDuration ?? 5),
      title: Text(
        (systemMessage != null && systemMessage) ? "System: $content" : content,
        maxLines: 10,
      ),
      icon: Icon(LucideIcons.hexagon),
    );
  }

  static void soon(bool isArabic) {
    systemToast("${isArabic ? "قريبا" : "soon"}...");
  }
}
