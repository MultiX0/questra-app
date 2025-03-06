import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

void fcmSubscribe(String topic) {
  firebaseMessaging.subscribeToTopic(topic);
}

void fcmUnSubscribe(String topic) {
  firebaseMessaging.unsubscribeFromTopic(topic);
}
