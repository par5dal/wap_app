// lib/core/router/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wap_app/features/auth/presentation/pages/auth_shell_page.dart';
import 'package:wap_app/features/auth/presentation/pages/unified_auth_page.dart';
import 'package:wap_app/features/home/presentation/pages/home_page.dart';
import 'package:wap_app/presentation/pages/splash_screen_page.dart';
import 'package:wap_app/features/profile/presentation/pages/profile_page.dart';
import 'package:wap_app/features/discovery/presentation/pages/categories_explorer_page.dart';
import 'package:wap_app/features/discovery/presentation/pages/category_events_page.dart';
import 'package:wap_app/features/discovery/data/models/category_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wap_app/features/discovery/presentation/pages/promoters_directory_page.dart';
import 'package:wap_app/features/event_detail/presentation/pages/event_detail_loader_page.dart';
import 'package:wap_app/features/event_detail/presentation/pages/event_detail_page.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/core/services/notification_service.dart';
import 'package:wap_app/core/services/analytics_service.dart';
import 'package:wap_app/features/preferences/presentation/pages/settings_page.dart';
import 'package:wap_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:wap_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:wap_app/features/auth/presentation/pages/terms_page.dart';
import 'package:wap_app/features/auth/presentation/pages/force_update_page.dart';
import 'package:wap_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:wap_app/presentation/pages/suspended_page.dart';

enum AppRoute {
  splash,
  auth,
  home,
  profile,
  settings,
  categoriesExplorer,
  promotersDirectory,
  categoryEvents,
  eventDetail,
  eventDetailDirect,
  forgotPassword,
  changePassword,
  notifications,
  terms,
  suspended,
  forceUpdate,
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final goRouter = GoRouter(
  initialLocation: '/home', // ✅ Inicio público
  observers: [sl<AnalyticsService>().observer],
  refreshListenable: GoRouterRefreshStream(sl<AppBloc>().stream),
  errorPageBuilder: (context, state) {
    // Si el error viene de un URI con scheme wap://, es el deep link OAuth
    // siendo procesado por GoRouter antes de que app_links lo maneje.
    // Mostrar spinner en vez de 404 para que goNamed() lo reemplace inmediatamente.
    final uri = state.uri;
    if (uri.scheme == 'wap') {
      return const MaterialPage(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return const MaterialPage(
      child: Scaffold(body: Center(child: Text('404 - Página no encontrada'))),
    );
  },
  routes: [
    GoRoute(
      name: AppRoute.splash.name,
      path: '/splash',
      builder: (context, state) => const SplashScreenPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: AuthShellPage(state: state, child: child),
        );
      },
      routes: [
        GoRoute(
          name: AppRoute.auth.name,
          path: '/auth',
          builder: (context, state) => const UnifiedAuthPage(),
        ),
      ],
    ),
    GoRoute(
      name: AppRoute.home.name,
      path: '/home',
      builder: (context, state) => const HomePage(), // ✅ Público
    ),
    GoRoute(
      name: AppRoute.profile.name,
      path: '/profile',
      builder: (context, state) => const ProfilePage(), // Requiere auth
    ),
    GoRoute(
      name: AppRoute.settings.name,
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      name: AppRoute.categoriesExplorer.name,
      path: '/categories',
      builder: (context, state) => const CategoriesExplorerPage(), // Público
    ),
    GoRoute(
      name: AppRoute.categoryEvents.name,
      path: '/categories/:slug/events',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final extra = state.extra;

        CategoryModel category;
        LatLng? userLocation;

        if (extra is Map) {
          category =
              extra['category'] as CategoryModel? ??
              CategoryModel(
                id: '',
                name: slug.replaceAll('-', ' ').toUpperCase(),
                slug: slug,
                svg: '',
                color: '#007AFF',
                isActive: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          userLocation = extra['userLocation'] as LatLng?;
        } else if (extra is CategoryModel) {
          category = extra;
        } else {
          category = CategoryModel(
            id: '',
            name: slug.replaceAll('-', ' ').toUpperCase(),
            slug: slug,
            svg: '',
            color: '#007AFF',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        return CategoryEventsPage(
          category: category,
          userLocation: userLocation,
        );
      },
    ),
    GoRoute(
      name: AppRoute.promotersDirectory.name,
      path: '/promoters',
      builder: (context, state) => const PromotersDirectoryPage(), // Público
    ),
    GoRoute(
      name: AppRoute.eventDetail.name,
      path: '/events/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EventDetailLoaderPage(eventId: id);
      },
    ),
    GoRoute(
      name: AppRoute.eventDetailDirect.name,
      path: '/event-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final event = state.extra as Event?;
        // extra es efímero en GoRouter: se pierde cuando GoRouterRefreshStream
        // reconstruye las rutas (p.ej. al cambiar el estado de auth).
        // Si ocurre, recargamos el evento desde la API con EventDetailLoaderPage
        // usando el ID que sí está persistido en la URL.
        if (event == null) {
          return EventDetailLoaderPage(eventId: id);
        }
        return EventDetailPage(event: event);
      },
    ),
    GoRoute(
      name: AppRoute.forgotPassword.name,
      path: '/forgot-password',
      builder: (context, state) {
        final email = state.extra as String?;
        return ForgotPasswordPage(initialEmail: email);
      },
    ),
    GoRoute(
      name: AppRoute.changePassword.name,
      path: '/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      name: AppRoute.notifications.name,
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      name: AppRoute.terms.name,
      path: '/terms',
      builder: (context, state) => const TermsPage(),
    ),
    GoRoute(
      name: AppRoute.suspended.name,
      path: '/suspended',
      builder: (context, state) => const SuspendedPage(),
    ),
    GoRoute(
      name: AppRoute.forceUpdate.name,
      path: '/force-update',
      builder: (context, state) => const ForceUpdatePage(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    // Cold start: si la app arrancó al tocar una notificación, navegar
    // directamente al destino. Se ejecuta dentro del ciclo de GoRouter,
    // sin depender de frame callbacks ni timing externo.
    final pendingMsg = sl<NotificationService>().pendingInitialMessage;
    if (pendingMsg != null) {
      sl<NotificationService>().consumePendingInitialMessage();
      final type = pendingMsg.data['type'] ?? '';
      final eventId = pendingMsg.data['event_id'] ?? '';
      if (type == 'new_event' && eventId.isNotEmpty) {
        return '/events/$eventId';
      }
    }

    final appStatus = sl<AppBloc>().state.status;
    final location = state.matchedLocation;

    // Rutas protegidas que requieren autenticación
    final protectedRoutes = ['/profile', '/change-password', '/notifications'];
    final isProtectedRoute = protectedRoutes.contains(location);

    // Si estamos en splash y ya se checkeo el estado, ir al home
    if (appStatus != AuthStatus.unknown && location == '/splash') {
      return '/home';
    }

    // Si la versión instalada es obsoleta, bloquear toda navegación
    if (appStatus == AuthStatus.updateRequired && location != '/force-update') {
      return '/force-update';
    }
    if (location == '/force-update' && appStatus != AuthStatus.updateRequired) {
      return '/home';
    }

    // Si la cuenta está suspendida, redirigir a /suspended
    if (appStatus == AuthStatus.suspended && location != '/suspended') {
      return '/suspended';
    }

    // Si los T&C no han sido aceptados, redirigir a /terms
    if (appStatus == AuthStatus.termsNotAccepted && location != '/terms') {
      return '/terms';
    }

    // Si estamos en /terms pero ya no estamos en estado termsNotAccepted,
    // redirigir al home (ej. tras aceptar T&C o al cerrar sesión desde /terms)
    if (location == '/terms' && appStatus != AuthStatus.termsNotAccepted) {
      return '/home';
    }

    // Si intentamos acceder a una ruta protegida sin auth, ir a login
    if (isProtectedRoute && appStatus == AuthStatus.unauthenticated) {
      return '/auth';
    }

    // Si estamos autenticados y vamos al auth, redirigir al home
    if (appStatus == AuthStatus.authenticated && location == '/auth') {
      return '/home';
    }

    return null;
  },
);
