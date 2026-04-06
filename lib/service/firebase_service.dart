import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    try {
      // Solicitar permissão
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Permission status: ${settings.authorizationStatus}');

      // Inicializar notificações locais
      await _initializeLocalNotifications();

      // Obter FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');

      // Lidar com mensagens em primeiro plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Message received in foreground');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        
        // Exibir notificação local
        _showNotification(message);
      });

      // Lidar com mensagens quando o app é aberto de notificação
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message opened app');
        print('Title: ${message.notification?.title}');
      });
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _localNotifications.initialize(settings: initSettings);
      print('Local notifications initialized');
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'fcm_channel',
        'Firebase Messages',
        channelDescription: 'Notifications from Firebase',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Notificação',
        body: message.notification?.body ?? '',
        notificationDetails: notificationDetails,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      print('Current FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> testFirebaseConnection() async {
    try {
      print('=== Testing Firebase Connection ===');
      final token = await getFCMToken();
      print('FCM Token: $token');
      print('=== Test Complete ===');
    } catch (e) {
      print('Firebase Error: $e');
    }
  }
}