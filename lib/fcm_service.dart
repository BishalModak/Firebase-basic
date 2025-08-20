import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    //on app running
    FirebaseMessaging.onMessage.listen(_handleBackgroundNotification);
    //background/hide/minimize
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotification);
    //terminated
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
  }

  void _handleBackgroundNotification(RemoteMessage message) {
    print(message.notification?.title);
    print(message.notification?.body);
    print(message.data);
  }

  Future<String?> getFcmToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> onTockenRefresh() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((String? newToken) {
      print('Sending To Server');
    });
  }
}

Future<void> handleBackgroundNotification(RemoteMessage message) async {
  print(message.notification?.title);
  print(message.notification?.body);
  print(message.data);
}
