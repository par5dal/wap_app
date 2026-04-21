// lib/main.dart

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/config/env_config.dart';
import 'package:wap_app/core/services/notification_service.dart';
import 'package:wap_app/core/services/connectivity_service.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wap_app/shared/widgets/no_connection_banner.dart';

import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/presentation/bloc/locale/locale_cubit.dart';
import 'package:wap_app/presentation/bloc/theme/theme_cubit.dart';
import 'package:wap_app/core/theme/app_theme.dart';

/// Clave global para mostrar SnackBars desde fuera del widget tree (ej. notificaciones).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Paso 1: orientación (no bloquea el arranque)
  unawaited(
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  );

  const iosDsn =
      'https://726761e40e2dcfe19095f0f3dcc873e4@o4510172185296896.ingest.de.sentry.io/4510856293777488';
  const androidDsn =
      'https://c6105a00a779576bcdf39f1a65d42b67@o4510172185296896.ingest.de.sentry.io/4510172187983952';
  final isAndroid =
      const bool.fromEnvironment('dart.library.io') && Platform.isAndroid;

  // Paso 2: dotenv — falla inmediatamente si el asset no está en el bundle
  await dotenv.load(fileName: '.env');
  debugPrint('[INIT] dotenv OK – ENV suffix: ${EnvConfig.suffix}');

  // Paso 3: Sentry ANTES de Firebase — solo necesita WidgetsFlutterBinding.
  // Así si Firebase (o cualquier paso posterior) falla, Sentry ya está activo
  // y _runErrorApp puede mostrar el error en pantalla.
  await SentryFlutter.init(
    (options) {
      options.dsn = isAndroid ? androidDsn : iosDsn;
      options.environment = EnvConfig.isProduction
          ? 'production'
          : 'development';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      await runZonedGuarded(
        () async {
          // Paso 4: Firebase — dentro del zone guarded para que cualquier
          // excepción sea capturada por Sentry y mostrada en pantalla.
          // SIN timeout: .timeout() en channel nativo iOS causa [core/not-initialized].
          await Firebase.initializeApp();
          debugPrint('[INIT] Firebase OK');

          await di.initDI();
          debugPrint('[INIT] DI OK');

          _initDeepLinkListener();

          await di.sl<NotificationService>().initialize().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              // FCM timeout NO es fatal — la app arranca igualmente sin push
              debugPrint('[INIT] NotificationService timeout (no fatal)');
            },
          );
          _initNotificationListeners();

          di.sl<AppBloc>().add(AppStatusChecked());

          runApp(const MyApp());
        },
        (exception, stackTrace) async {
          debugPrint('[INIT ERROR] $exception\n$stackTrace');
          await Sentry.captureException(exception, stackTrace: stackTrace);
          _runErrorApp('$exception\n\n$stackTrace');
        },
      );
    },
  );
}

/// Muestra un error crítico en pantalla cuando el arranque falla.
/// Solo se usa como diagnóstico — no aparece en condiciones normales.
void _runErrorApp(String message) {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFEBEE),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⛔ Error de arranque',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  message,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
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
    final eventSlug = message.data['slug'] as String?;
    final hasEventTarget =
        type == 'new_event' && eventSlug != null && eventSlug.isNotEmpty;

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
                  goRouter.push('/events/$eventSlug');
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
    final eventSlug = message.data['slug'] as String?;
    if (type == 'new_event' && eventSlug != null && eventSlug.isNotEmpty) {
      goRouter.push('/events/$eventSlug');
    } else {
      goRouter.go('/home');
    }
  });
}

/// Configura el listener de deep links para capturar eventos compartidos.
void _initDeepLinkListener() {
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen(
    (uri) async {
      AppLogger.info('🔗 Deep link recibido: $uri');
      // Eventos compartidos: https://www.whataplan.net/{lang}/eventos/{slug}
      final isEventLink =
          (uri.host == 'whataplan.net' || uri.host == 'www.whataplan.net') &&
          uri.pathSegments.length == 3 &&
          uri.pathSegments[1] == 'eventos';
      if (isEventLink) {
        final eventSlug = uri.pathSegments[2];
        AppLogger.info('🔗 Deep link evento: $eventSlug');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        goRouter.go('/events/$eventSlug');
      }
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
