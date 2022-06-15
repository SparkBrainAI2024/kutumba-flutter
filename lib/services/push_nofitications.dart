
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print(message);
}

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      _firebaseMessaging.getInitialMessage().then((RemoteMessage message) {
        if (message != null) {
          print('onmessage');

          print(message);
          RemoteNotification notification = message.notification;
          showNotification(notification);
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        RemoteNotification notification = message.notification;
        showNotification(notification);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        RemoteNotification notification = message.notification;
        showNotification(notification);
      });

      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }

  showNotification(RemoteNotification notification) {
    showOverlay((context, t) {
      return AlertDialog(
        title: Text(notification.title),
        content: notification.body == null
            ? null
            : SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(notification.body),
                  ],
                ),
              ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              OverlaySupportEntry.of(context).dismiss();
            },
          ),
        ],
      );
    }, duration: Duration.zero);
  }

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
