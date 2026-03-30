// lib/core/services/notification_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/utils/app_logger.dart';

/// Handler de mensajes en background — DEBE ser una función top-level.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase SDK ya está inicializado en el isolate de background por el plugin.
  AppLogger.info('📬 FCM background message: ${message.data}');
}

class NotificationService {
  final Dio _dio;
  final SharedPreferences _prefs;

  NotificationService({
    required Dio dio,
    required SharedPreferences sharedPreferences,
  }) : _dio = dio,
       _prefs = sharedPreferences;

  static const _supportedLangs = ['es', 'en', 'pt'];

  /// Devuelve el código de idioma que se debe enviar al backend.
  /// Si el usuario eligió un idioma específico en la app, lo usa.
  /// Si eligió "idioma del dispositivo" (null guardado), detecta el locale
  /// real del dispositivo y lo mapea a es/en/pt (fallback: 'es').
  String _resolveBackendLang() {
    final stored = _prefs.getString('app_locale');
    if (stored != null) return stored;
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return _supportedLangs.contains(deviceCode) ? deviceCode : 'es';
  }

  /// Devuelve el valor de tema que se debe enviar al backend: 'light', 'dark' o 'system'.
  String _resolveBackendTheme() {
    return _prefs.getString('app_theme') ?? 'system';
  }

  final _foregroundController = StreamController<RemoteMessage>.broadcast();
  final _tapController = StreamController<RemoteMessage>.broadcast();

  /// Mensajes recibidos mientras la app está en primer plano.
  Stream<RemoteMessage> get foregroundMessages => _foregroundController.stream;

  /// Usuario toca una notificación (app en background o terminada).
  Stream<RemoteMessage> get notificationTaps => _tapController.stream;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  RemoteMessage? _pendingInitialMessage;

  /// Mensaje de cold start capturado en [initialize].
  /// GoRouter lo lee en su función `redirect` para navegar al destino
  /// sin depender de frame callbacks ni streams.
  RemoteMessage? get pendingInitialMessage => _pendingInitialMessage;

  /// Marca el mensaje de cold start como consumido.
  void consumePendingInitialMessage() => _pendingInitialMessage = null;

  /// Inicializar todos los listeners FCM.
  /// Llamar una sola vez después de Firebase.initializeApp().
  Future<void> initialize() async {
    // Handler para mensajes en background (isolate separado)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // iOS: mostrar notificaciones del sistema incluso en primer plano
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Mensajes recibidos con la app en primer plano → emitir al stream
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      AppLogger.info('📩 FCM foreground: ${message.notification?.title}');
      _foregroundController.add(message);
    });

    // Renovación automática del token de dispositivo → actualizar en backend
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      newToken,
    ) async {
      AppLogger.info('🔄 FCM token renovado, actualizando backend...');
      await _patchToken(newToken);
    });

    // Usuario toca notificación cuando la app estaba en background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AppLogger.info('🔔 Notificación tocada (background): ${message.data}');
      _tapController.add(message);
    });

    // Usuario toca notificación cuando la app estaba cerrada (cold start).
    // Guardamos el mensaje y lo emitimos después, cuando el router ya
    // esté montado, mediante replayInitialMessage().
    _pendingInitialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (_pendingInitialMessage != null) {
      AppLogger.info(
        '🔔 Mensaje inicial guardado (cold start): ${_pendingInitialMessage!.data}',
      );
    }
  }

  /// Pedir permiso, obtener el token FCM y registrarlo en el backend.
  /// Llamar después de que el usuario inicie sesión.
  Future<void> registerToken() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final status = settings.authorizationStatus;
      if (status != AuthorizationStatus.authorized &&
          status != AuthorizationStatus.provisional) {
        AppLogger.warning('⚠️ Permiso FCM no concedido: $status');
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        AppLogger.warning('⚠️ FCM token es null');
        return;
      }

      await _patchToken(token);
    } catch (e) {
      AppLogger.warning('⚠️ FCM registerToken error: $e');
    }
  }

  /// Enviar null al backend para desregistrar el dispositivo.
  /// Llamar antes de hacer logout.
  Future<void> unregisterToken() async {
    await _patchToken(null);
  }

  Future<void> _patchToken(String? token) async {
    try {
      // DioInterceptor añade automáticamente el header Authorization con el
      // Firebase ID token, no es necesario manejarlo explícitamente aquí.
      final lang = token != null ? _resolveBackendLang() : null;
      final theme = token != null ? _resolveBackendTheme() : null;
      await _dio.patch(
        '/users/me/fcm-token',
        data: {
          'token': token,
          if (lang != null) 'lang': lang,
          if (theme != null) 'theme': theme,
        },
      );
      AppLogger.info(
        '✅ FCM token ${token == null ? 'desregistrado' : 'registrado'} en backend${lang != null ? ' (lang: $lang, theme: $theme)' : ''}',
      );
    } catch (e) {
      AppLogger.warning('⚠️ FCM token PATCH fallido: $e');
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _foregroundController.close();
    _tapController.close();
  }
}
