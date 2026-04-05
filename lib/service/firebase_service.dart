import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static Future<void> testFirebaseConnection() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      print('FCM Token: $token');
      
      final settings = await messaging.requestPermission();
      print('Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('Firebase Error: $e');
    }
  }
}