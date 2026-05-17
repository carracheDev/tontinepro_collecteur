import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

// Handler de background message (doit être top-level)
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();

  static const _channelId = 'tontinepro_collecteur_channel';
  static const _channelName = 'TontinePro Collecteur';

  // Token FCM disponible après init()
  String? token;

  // Callback de navigation injecté depuis app.dart
  void Function(String route, {Object? extra})? _onNavigate;

  void setNavigationCallback(void Function(String, {Object? extra}) cb) {
    _onNavigate = cb;
  }

  Future<void> init() async {
    // 1. Permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 2. Canal Android + plugin local notifications
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        _gererTap(details.payload);
      },
    );

    // 3. Background handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // 4. Foreground messages → notification locale
    FirebaseMessaging.onMessage.listen((message) {
      _afficherNotifLocale(message);
    });

    // 5. Tap quand app en background (pas terminée)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _gererTapMessage(message);
    });

    // 6. Tap quand app était terminée
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      // Léger délai pour que le router soit prêt
      await Future.delayed(const Duration(milliseconds: 800));
      _gererTapMessage(initial);
    }

    // 7. Récupérer le token
    token = await _messaging.getToken();

    // 8. Écouter les renouvellements de token
    _messaging.onTokenRefresh.listen((newToken) {
      token = newToken;
    });
  }

  void _afficherNotifLocale(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['route']?.toString(),
    );
  }

  void _gererTapMessage(RemoteMessage message) {
    final route = message.data['route']?.toString();
    _gererTap(route);
  }

  void _gererTap(String? route) {
    if (route == null || _onNavigate == null) return;
    _onNavigate!(route);
  }

  /// À appeler après un login réussi pour enregistrer le token FCM côté backend.
  /// Silencieux en cas d'erreur (ne bloque pas le flux auth).
  Future<void> enregistrerTokenBackend() async {
    final t = token ?? await _messaging.getToken();
    if (t == null) return;
    try {
      await DioClient.instance.post(
        ApiEndpoints.notificationsTokenPush,
        data: {'tokenPush': t},
      );
    } catch (_) {
      // Échec silencieux — le token sera re-tenté au prochain login
    }
  }
}
