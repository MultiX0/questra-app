import 'dart:developer';

import 'package:flutter/services.dart';

class PackageInfoService {
  static Future<String> getAppVersion() async {
    try {
      const platform = MethodChannel('appVersionChannel');
      final result = await platform.invokeMethod('getAppInfo');
      final version = result['version'];
      final buildNumber = result['buildNumber'];
      log('Version: $version, Build: $buildNumber');
      return version.toString();
    } on PlatformException catch (e) {
      log('Failed: ${e.message}');
      rethrow;
    }
  }

  static Future<String> getAppBuildNumber() async {
    try {
      const platform = MethodChannel('appVersionChannel');
      final result = await platform.invokeMethod('getAppInfo');
      final buildNumber = result['buildNumber'];
      return buildNumber.toString();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
