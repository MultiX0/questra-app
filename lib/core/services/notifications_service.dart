import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsService {
  static Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
