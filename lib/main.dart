// lib/main.dart

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/config/firebase_options.dart';
import 'package:wap_app/core/services/notification_service.dart';
import 'package:wap_app/core/services/connectivity_service.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wap_app/shared/widgets/no_connection_banner.dart';
import 'package:dio/dio.dart';

import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/presentation/bloc/locale/locale_cubit.dart';
import 'package:wap_app/presentation/bloc/theme/theme_cubit.dart';
import 'package:wap_app/core/theme/app_theme.dart';

/// Clave global para mostrar SnackBars desde fuera del widget tree (ej. notificaciones).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await di.initDI();

      // Configurar listener de deep links (OAuth callback de Google)
      _initDeepLinkListener();

      // Inicializar FCM: registrar handler de background y escuchar mensajes
      await di.sl<NotificationService>().initialize();
      _initNotificationListeners();

      // Disparamos el evento al AppBloc global para que empiece a comprobar el estado de la sesión.
      di.sl<AppBloc>().add(
        AppStatusChecked(),
      ); // O un evento 'CheckStatus' dedicado

      await SentryFlutter.init((options) {
        // Usar DSN específico por plataforma
        final isAndroid =
            const bool.fromEnvironment('dart.library.io') && Platform.isAndroid;
        final dsn = isAndroid
            ? dotenv.env['SENTRY_DSN_ANDROID'] ?? dotenv.env['SENTRY_DSN']
            : dotenv.env['SENTRY_DSN_IOS'] ?? dotenv.env['SENTRY_DSN'];

        options.dsn = dsn;
        options.tracesSampleRate = 1.0;

        // Filtrar errores que no deben reportarse a Sentry
        options.beforeSend = (event, hint) async {
          // Filtrar errores de ubicación (son esperados en el flujo normal)
          final exceptionType = event.throwable?.runtimeType.toString() ?? '';
          if (exceptionType.isNotEmpty &&
              (exceptionType.contains('LocationServiceDisabledException') ||
                  exceptionType.contains('LocationPermissionDeniedException') ||
                  exceptionType.contains(
                    'LocationPermissionDeniedForeverException',
                  ))) {
            // No reportar estos errores a Sentry
            return null;
          }

          // También verificar en el mensaje de error
          final eventMessage = event.message?.formatted ?? '';
          if (eventMessage.contains('LocationServiceDisabledException') ||
              eventMessage.contains('LocationPermissionDeniedException') ||
              eventMessage.contains(
                'LocationPermissionDeniedForeverException',
              )) {
            return null;
          }

          // Filtrar errores Dio de conectividad — son esperados cuando el
          // usuario no tiene internet y se gestionan en la UI con el banner.
          final throwable = event.throwable;
          if (throwable is DioException &&
              (throwable.type == DioExceptionType.connectionTimeout ||
                  throwable.type == DioExceptionType.receiveTimeout ||
                  throwable.type == DioExceptionType.sendTimeout ||
                  throwable.type == DioExceptionType.connectionError)) {
            return null;
          }

          // Filtrar errores Dio 403 — el interceptor ya los maneja (T&C no
          // aceptados, cuenta suspendida) y navega a la pantalla apropiada.
          // Reportarlos a Sentry es ruido puesto que el flujo está controlado.
          if (throwable is DioException &&
              throwable.response?.statusCode == 403) {
            return null;
          }

          // Añadir tags para identificar la plataforma
          event.tags = {
            ...?event.tags,
            'platform': isAndroid ? 'android' : 'ios',
          };
          return event;
        };
      }, appRunner: () => runApp(const MyApp()));
    },
    (exception, stackTrace) async {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    },
  );
}

/// Suscribe a los streams de NotificationService para mostrar SnackBars en primer
/// plano y navegar al tocar notificaciones en background/terminated.
void _initNotificationListeners() {
  final notificationService = di.sl<NotificationService>();

  // App en primer plano: mostrar SnackBar con título, cuerpo y acción de navegación
  notificationService.foregroundMessages.listen((message) {
    // Actualizar badge de notificaciones no leídas
    di.sl<NotificationsBloc>().add(const RefreshUnreadCount());

    // Intentar obtener título y cuerpo del payload de notificación.
    // Si el backend envía un mensaje solo-data (sin campo notification),
    // intentamos leerlos de los datos.
    final title =
        message.notification?.title ?? message.data['title'] as String? ?? '';
    final body =
        message.notification?.body ?? message.data['body'] as String? ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final type = message.data['type'];
    final eventId = message.data['event_id'];
    final hasEventTarget =
        type == 'new_event' && eventId != null && eventId.isNotEmpty;

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (body.isNotEmpty) Text(body),
          ],
        ),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        action: hasEventTarget
            ? SnackBarAction(
                label: 'Ver',
                onPressed: () {
                  // Mark notification as read if the FCM payload carries its ID
                  final notifId =
                      message.data['notification_id'] as String? ??
                      message.data['id'] as String?;
                  if (notifId != null && notifId.isNotEmpty) {
                    di.sl<NotificationsBloc>().add(
                      MarkNotificationRead(notifId),
                    );
                  } else {
                    // No ID in payload — at least refresh so badge clears
                    di.sl<NotificationsBloc>().add(const RefreshUnreadCount());
                  }
                  goRouter.push('/events/$eventId');
                },
              )
            : null,
      ),
    );
  });

  // Usuario toca una notificación en background → navegar al destino
  // (cold start lo gestiona directamente GoRouter en su redirect)
  notificationService.notificationTaps.listen((message) {
    // Actualizar badge al abrir la app desde notificación
    di.sl<NotificationsBloc>().add(const RefreshUnreadCount());

    final type = message.data['type'];
    final eventId = message.data['event_id'];
    if (type == 'new_event' && eventId != null && eventId.isNotEmpty) {
      goRouter.push('/events/$eventId');
    } else {
      goRouter.go('/home');
    }
  });
}

/// Configura el listener de deep links para capturar el callback OAuth de Google.
/// Supabase redirige a [deepLinkScheme]://auth/callback#access_token=...&refresh_token=...
void _initDeepLinkListener() {
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen(
    (uri) async {
      AppLogger.info('🔗 Deep link recibido: $uri');
      // Deriva el host del callback desde API_BASE_URL del .env
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final apiHost = Uri.tryParse(apiBaseUrl)?.host ?? '';
      // Acepta tanto https://{API_HOST}/auth/callback como wap://auth/callback
      // Deep link: evento compartido (https://www.whataplan.net/{lang}/eventos/{slug})
      final isEventLink =
          (uri.host == 'whataplan.net' || uri.host == 'www.whataplan.net') &&
          uri.pathSegments.length == 3 &&
          uri.pathSegments[1] == 'eventos';
      if (isEventLink) {
        final eventSlug = uri.pathSegments[2];
        AppLogger.info('🔗 Deep link evento: $eventSlug');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        goRouter.go('/events/$eventSlug');
        return;
      }

      final isOAuthCallback =
          (uri.host == apiHost && uri.path == '/auth/callback') ||
          (uri.host == 'whataplan.net' && uri.path == '/auth/callback') ||
          (uri.scheme == 'wap' && uri.path == '/callback');
      if (!isOAuthCallback) return;

      // Los tokens pueden venir en el fragment (#) si Supabase redirige directamente,
      // o en los query params (?) si vienen del endpoint mobile-callback del backend.
      final Map<String, String> tokenParams = uri.fragment.isNotEmpty
          ? Uri.splitQueryString(uri.fragment)
          : uri.queryParameters;

      final accessToken = tokenParams['access_token'];
      final refreshToken = tokenParams['refresh_token'];

      if (accessToken == null || refreshToken == null) {
        AppLogger.warning(
          '⚠️ Deep link de auth sin tokens: ${uri.fragment.isNotEmpty ? uri.fragment : uri.query}',
        );
        return;
      }

      // El proveedor viene en los query params del URI (e.g. ?provider=apple)
      final provider = uri.queryParameters['provider'] ?? 'google';

      // Pequeño delay para que el widget tree esté listo tras volver
      // del navegador (el engine puede estar aún reconstruyendo la UI).
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await closeInAppWebView();

      // goNamed reemplaza el stack completo → sobrescribe cualquier estado
      // de error que GoRouter mostrara al procesar el intent wap:// directamente.
      goRouter.goNamed(
        AppRoute.authCallback.name,
        extra: <String, dynamic>{
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'provider': provider,
        },
      );
    },
    onError: (e) =>
        AppLogger.error('Error en deep link listener', e, StackTrace.current),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiBlocProvider para que todos los BLoCs/Cubits globales
    // estén disponibles en toda la aplicación.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AppBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<LocaleCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final platformBrightness = MediaQuery.of(context).platformBrightness;
          final finalThemeMode = themeMode == ThemeMode.system
              ? (platformBrightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light)
              : themeMode;

          // Determinamos si el tema final que se va a mostrar es oscuro
          final isDarkMode = finalThemeMode == ThemeMode.dark;

          // Creamos el estilo de la barra de estado aquí
          // statusBarColor se omite: con edge-to-edge (SDK 35+) ya es transparente
          // por defecto y setStatusBarColor() está deprecado en API 35.
          final systemUiOverlayStyle = SystemUiOverlayStyle(
            statusBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
          );

          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'WAP App',
                scaffoldMessengerKey: scaffoldMessengerKey,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: finalThemeMode,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: goRouter,
                debugShowCheckedModeBanner: false,
                // El 'builder' envuelve a TODAS las páginas de la aplicación.
                builder: (context, child) {
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: systemUiOverlayStyle,
                    child: _ConnectivityObserver(child: child!),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Connectivity observer — wraps every page and shows a slim amber banner that
// slides OVER the content from the top (no layout shift) when offline,
// and auto-hides + refreshes events on reconnect.
// ---------------------------------------------------------------------------

class _ConnectivityObserver extends StatefulWidget {
  const _ConnectivityObserver({required this.child});
  final Widget child;

  @override
  State<_ConnectivityObserver> createState() => _ConnectivityObserverState();
}

class _ConnectivityObserverState extends State<_ConnectivityObserver> {
  StreamSubscription<bool>? _sub;
  bool _isOffline = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // Verificar el estado actual de conectividad al arrancar.
    // La stream onConnectivityChanged solo emite CAMBIOS, no el estado inicial,
    // por lo que si la app arranca sin internet el banner no aparecería nunca.
    di.sl<ConnectivityService>().checkNow().then((isConnected) {
      if (mounted) setState(() => _isOffline = !isConnected);
    });

    _sub = di.sl<ConnectivityService>().isConnected.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(bool isConnected) {
    if (!mounted) return;
    setState(() => _isOffline = !isConnected);
    if (isConnected) {
      try {
        di.sl<HomeBloc>().add(const RefreshEvents());
      } catch (_) {
        // HomeBloc may not be registered yet during startup — ignore
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        widget.child,
        if (t != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_isOffline,
              child: AnimatedSlide(
                offset: _isOffline ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 6,
                    16,
                    10,
                  ),
                  child: NoConnectionBanner(message: t.noConnectionBanner),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
