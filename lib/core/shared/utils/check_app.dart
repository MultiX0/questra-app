import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

Future<bool> isInstalledFromPlayStore() async {
  if (!Platform.isAndroid) return false; // Only for Android

  final packageInfo = await PackageInfo.fromPlatform();
  final installer = packageInfo.installerStore ?? 'unknown'; // Get installer

  return installer.contains("com.android.vending") || // Google Play Store
      installer.contains("com.google.android.feedback");
}
