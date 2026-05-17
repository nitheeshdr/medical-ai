import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled here when app is terminated/in background
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(apiClientProvider));
});

class NotificationService {
  final ApiClient _api;
  final _local = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;

  static const _channelId = 'medinova_channel';
  static const _channelName = 'MediNova AI';

  NotificationService(this._api);

  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Local notifications init
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Health reminders, appointment alerts, and AI insights',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground FCM messages → show as local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened from a notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // iOS foreground presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getFcmToken() => _messaging.getToken();

  Future<void> registerTokenWithBackend() async {
    try {
      final token = await getFcmToken();
      if (token == null) return;
      await _api.post(ApiEndpoints.fcmToken, data: {'token': token});
      _messaging.onTokenRefresh.listen((newToken) async {
        try {
          await _api.post(ApiEndpoints.fcmToken, data: {'token': newToken});
        } catch (_) {}
      });
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    show(notification.title ?? 'MediNova AI', notification.body ?? '');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // TODO: navigate to message.data['route'] when deep linking is wired up
  }

  Future<void> show(String title, String body) async {
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
