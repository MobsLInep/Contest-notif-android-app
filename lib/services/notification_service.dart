import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const String _backendUrl = 'https://scraper-api-j7tm.onrender.com/api'; // Updated to deployed backend

  // Notification settings keys
  static const String _key30min = 'notification_30min';
  static const String _key10min = 'notification_10min';
  static const String _keyCustom = 'notification_custom';
  static const String _keyLive = 'notification_live';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyDeviceId = 'device_id';

  Future<void> initialize() async {
    // Request permission for notifications
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Get FCM token
    final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _saveFcmToken(fcmToken);
        await _registerTokenWithBackend(fcmToken);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await _saveFcmToken(newToken);
        await _registerTokenWithBackend(newToken);
      });

    // Listen to Firebase messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      if (message.notification != null) {
          // No local notification, just log
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  }

  // Save FCM token locally
  Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, token);
  }

  // Get stored FCM token
  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  // Register token with your backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse('$_backendUrl/register-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          'fcmToken': token,
          'notificationSettings': await getNotificationSettings(),
        }),
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
      // Intentionally left empty: ignore errors during FCM token registration
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? notify30min,
    bool? notify10min,
    bool? notifyCustom,
    bool? notifyLive,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (notify30min != null) await prefs.setBool(_key30min, notify30min);
    if (notify10min != null) await prefs.setBool(_key10min, notify10min);
    if (notifyCustom != null) await prefs.setBool(_keyCustom, notifyCustom);
    if (notifyLive != null) await prefs.setBool(_keyLive, notifyLive);

    // Update settings on backend
    final token = await getFcmToken();
    if (token != null) {
      await _registerTokenWithBackend(token);
    }
  }

  // Get current notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'notify30min': prefs.getBool(_key30min) ?? true,
      'notify10min': prefs.getBool(_key10min) ?? true,
      'notifyCustom': prefs.getBool(_keyCustom) ?? true,
      'notifyLive': prefs.getBool(_keyLive) ?? true,
    };
  }

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }
    return deviceId;
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    try {
      final token = await getFcmToken();
      if (token == null) {
        return;
      }

      final response = await http.post(
        Uri.parse('$_backendUrl/send-test-notification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fcmToken': token,
          'title': 'Test Notification',
          'body': 'This is a test notification from your app!',
          'data': {
            'type': 'test',
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        }),
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
      // Intentionally left empty: ignore errors during test notification sending
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    
    switch (type) {
      case 'contest_start':
        // Navigate to contest details
        break;
      case 'contest_reminder':
        // Navigate to contest details
        break;
      case 'test':
        // Handle test notification tap
        break;
      default:
    }
  }

  // Clear user data when logging out
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceId);
    await prefs.remove(_keyFcmToken);
  }
}

// This needs to be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  
  if (message.notification != null) {
  }
} 