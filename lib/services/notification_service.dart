// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _logger.d('Authorization status: ${settings.authorizationStatus}');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      final token = await _messaging.getToken();
      _logger.d('FCM Token: $token');

      // Subscribe to topic
      await _messaging.subscribeToTopic('all');
      _logger.d('Subscribed to topic: all');

      // Configure FCM handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Check for initial message
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      _logger.e('Error initializing notifications: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialization = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iOSInitialization,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        _handleNotificationTap(details);
      },
    );

    // Create Android notification channel
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'default', // id
      'Default Channel', // title
      description: 'Default notification channel', // description
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.d('Got a message in foreground!');
    _logger.d('Message data: ${message.data}');
    _logger.d('Message notification: ${message.notification?.title}');

    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default',
            'Default Channel',
            channelDescription: 'Default notification channel',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.d('Message opened app: ${message.data}');
    // Handle navigation based on message data
    _handleNotificationTap(NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
      payload: message.data.toString(),
    ));
  }

  void _handleNotificationTap(NotificationResponse details) {
    // Implement navigation logic based on notification data
    _logger.d('Notification tapped: ${details.payload}');
  }

  Future<void> sendCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? topic,
  }) async {
    try {
      _logger.d('Sending notification:');
      _logger.d('Title: $title');
      _logger.d('Body: $body');
      _logger.d('Data: $data');
      _logger.d('Topic: $topic');

      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'title': title,
          'body': body,
          'data': data ?? {},
          'topic': topic ?? 'all',
        },
      );

      _logger.d('Response status: ${response.status}');
      _logger.d('Response data: ${response.data}');

      if (response.status != 200) {
        throw 'Failed to send notification: ${response.data}';
      }

      _logger.d('Notification sent successfully');
    } catch (e) {
      _logger.e('Error sending notification: $e');
      rethrow;
    }
  }
}

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Initialize Firebase if needed for background messages
  // await Firebase.initializeApp();
}