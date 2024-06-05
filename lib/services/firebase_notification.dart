import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}

void handleMessage(RemoteMessage? message){
  if(message == null) return;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
  final message = RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!));
  print(message.messageId);
}

class FirebaseConf{

  final _androidChanel = const AndroidNotificationChannel(
    'high_importance_channel', 
    'High Important Notifications',
    description: 'Canal para notificaciones importantes',
    importance: Importance.defaultImportance
    );
  
  var _localNotifications = FlutterLocalNotificationsPlugin();

  Future initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if(notification == null) return;
      _localNotifications.show(
        notification.hashCode, 
        notification.title, 
        notification.body, 
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChanel.id, 
            _androidChanel.name,
            playSound: true,
            importance: Importance.max,
            channelDescription: _androidChanel.description,
            icon: '@drawable/icon'
          ),
          iOS: const DarwinNotificationDetails(
            presentBadge: true
          )

        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  static Future getDeviceToken() async{
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("Token: $fcmToken");

  }

  Future initLocalNotifications() async{
  const iOS = DarwinInitializationSettings();
  const android = AndroidInitializationSettings('@drawable/icon');

  const settings = InitializationSettings(android: android, iOS: iOS);

  await _localNotifications.initialize(
    settings,
    /*onDidReceiveBackgroundNotificationResponse: (details) {
      final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
      //handleMessage(message);
      myBackgroundMessageHandler(message);
    },*/
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // ...
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await platform?.createNotificationChannel(_androidChanel);
}



Future<void> initNotifications() async{
  getDeviceToken();
  requestNotificationPermission();
  // fcmToken = await FirebaseMessaging.instance.getToken();
  // print("Token: $fcmToken");
  await initPushNotifications();
  initLocalNotifications();
}


Future<void> requestNotificationPermission()async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}


}

