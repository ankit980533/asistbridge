import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }
  
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    debugPrint('Received background message: ${message.notification?.title}');
  }
  
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
  
  static void onTokenRefresh(Function(String) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}
