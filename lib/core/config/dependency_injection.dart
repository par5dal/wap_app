// lib/core/config/dependency_injection.dart

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

// AUTH Feature
import 'package:wap_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wap_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/features/auth/domain/usecases/get_auth_status.dart';
import 'package:wap_app/features/auth/domain/usecases/login_user.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_apple.dart';
import 'package:wap_app/features/auth/domain/usecases/register_user.dart';
import 'package:wap_app/features/auth/domain/usecases/logout_user.dart';
import 'package:wap_app/features/auth/domain/usecases/check_email_exists.dart';
import 'package:wap_app/features/auth/presentation/bloc/auth_bloc.dart';

// EVENTS Feature
import 'package:wap_app/features/home/data/datasources/event_remote_data_source.dart';
import 'package:wap_app/features/home/data/datasources/location_data_source.dart';
import 'package:wap_app/features/home/data/datasources/event_tile_data_source.dart';
import 'package:wap_app/features/home/data/repositories/event_repository_impl.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';
import 'package:wap_app/features/home/domain/usecases/get_nearby_events.dart';
import 'package:wap_app/features/home/domain/usecases/get_events_for_map_bounds.dart';
import 'package:wap_app/features/home/domain/usecases/get_event_by_id.dart';
import 'package:wap_app/features/home/domain/usecases/record_event_view.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/home/presentation/providers/event_tile_provider.dart';

// Core Services
import 'package:wap_app/core/services/tile_math_service.dart';

// 🆕 PROFILE Feature
import 'package:wap_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:wap_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:wap_app/features/profile/domain/usecases/delete_avatar.dart';
import 'package:wap_app/features/profile/domain/usecases/get_my_profile.dart';
import 'package:wap_app/features/profile/domain/usecases/get_followed_promoters.dart';
import 'package:wap_app/features/profile/domain/usecases/get_blocked_promoters.dart';
import 'package:wap_app/features/profile/domain/usecases/update_my_profile.dart';
import 'package:wap_app/features/profile/domain/usecases/upload_avatar.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';

// 🆕 PROMOTER PROFILE Feature
import 'package:wap_app/features/promoter_profile/data/datasources/promoter_remote_data_source.dart';
import 'package:wap_app/features/promoter_profile/data/repositories/promoter_repository_impl.dart';
import 'package:wap_app/features/promoter_profile/domain/repositories/promoter_repository.dart';
import 'package:wap_app/features/promoter_profile/domain/usecases/get_promoter_profile.dart';
import 'package:wap_app/features/promoter_profile/domain/usecases/get_promoter_events.dart';

// 🆕 USER ACTIONS Feature
import 'package:wap_app/features/user_actions/data/datasources/user_actions_remote_data_source.dart';
import 'package:wap_app/features/user_actions/data/repositories/user_actions_repository_impl.dart';
import 'package:wap_app/features/user_actions/domain/repositories/user_actions_repository.dart';
import 'package:wap_app/features/user_actions/domain/usecases/add_event_to_favorites.dart';
import 'package:wap_app/features/user_actions/domain/usecases/remove_event_from_favorites.dart';
import 'package:wap_app/features/user_actions/domain/usecases/follow_promoter.dart';
import 'package:wap_app/features/user_actions/domain/usecases/unfollow_promoter.dart';
import 'package:wap_app/features/user_actions/domain/usecases/block_user.dart';
import 'package:wap_app/features/user_actions/domain/usecases/unblock_user.dart';

// 🆕 PREFERENCES Feature
import 'package:wap_app/features/preferences/data/datasources/preferences_remote_data_source.dart';
import 'package:wap_app/features/preferences/data/repositories/preferences_repository_impl.dart';
import 'package:wap_app/features/preferences/domain/repositories/preferences_repository.dart';
import 'package:wap_app/features/preferences/domain/usecases/get_preferences.dart';
import 'package:wap_app/features/preferences/domain/usecases/update_preferences.dart';

// 🆕 NOTIFICATIONS Feature
import 'package:wap_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:wap_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:wap_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:wap_app/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:wap_app/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:wap_app/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:wap_app/features/notifications/domain/usecases/delete_notification.dart';
import 'package:wap_app/features/notifications/domain/usecases/delete_all_notifications.dart';
import 'package:wap_app/features/notifications/presentation/bloc/notifications_bloc.dart';

// BLoCs Globales
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/presentation/bloc/locale/locale_cubit.dart';
import 'package:wap_app/presentation/bloc/theme/theme_cubit.dart';

// Reports Feature
import 'package:wap_app/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:wap_app/features/reports/domain/usecases/create_report.dart';

// Network
import 'package:wap_app/core/network/dio_interceptor.dart';
import 'package:wap_app/core/services/notification_service.dart';
import 'package:wap_app/core/services/analytics_service.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/core/services/app_version_service.dart';
import 'package:wap_app/core/services/connectivity_service.dart';
import 'package:wap_app/core/constants/app_constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Auth usecases (T&C)
import 'package:wap_app/features/auth/domain/usecases/get_terms_info.dart';
import 'package:wap_app/features/auth/domain/usecases/accept_terms.dart';
import 'package:wap_app/features/auth/domain/usecases/get_legal_document.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // --- Externo ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  final tempDir = await getTemporaryDirectory();
  final cacheStore = HiveCacheStore(tempDir.path);
  sl.registerSingleton<HiveCacheStore>(cacheStore);

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Analytics
  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(FirebaseAnalytics.instance),
  );

  // Connectivity
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // ========================================
  // CORE / NETWORK (Primero - sin interceptor de auth todavía)
  // ========================================
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL']!,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
      ),
    );

    final cacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.request,
      maxStale: const Duration(minutes: 10),
    );

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  });

  // Version check service (usa el mismo Dio con baseUrl pero sin interceptor de auth todavía)
  sl.registerLazySingleton<AppVersionService>(
    () => AppVersionService(dio: sl()),
  );

  // ========================================
  // FEATURE: AUTH (Segundo - necesita Dio)
  // ========================================

  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // ========================================
  // GLOBAL BLoCs (Tercero - necesita AuthRepository)
  // ========================================
  sl.registerLazySingleton(
    () => NotificationService(dio: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => AppBloc(authRepository: sl(), notificationService: sl()),
  );
  sl.registerLazySingleton(() => ThemeCubit(sl()));
  sl.registerLazySingleton(() => LocaleCubit(sl()));

  // ========================================
  // AÑADIR INTERCEPTOR DE AUTH AHORA
  // ========================================
  // Ahora que AppBloc existe, añadimos el interceptor de autenticación
  sl<Dio>().interceptors.add(
    DioInterceptor(dio: sl(), appBloc: sl()),
  );

  // ========================================
  // FEATURE: AUTH - UseCases y BLoCs
  // ========================================

  // UseCases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GetAuthStatusUseCase());
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithAppleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckEmailExistsUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      loginWithGoogle: sl(),
      loginWithApple: sl(),
      checkEmailExists: sl(),
      appBloc: sl(),
      prefs: sl(),
    ),
  );

  // ========================================
  // FEATURE: EVENTS
  // ========================================

  // DataSources
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<EventTileService>(() => EventTileService(sl()));

  // Core Services
  sl.registerLazySingleton<TileMathService>(() => TileMathService());

  // Providers
  sl.registerLazySingleton<EventTileProvider>(
    () => EventTileProvider(sl(), sl()),
  );

  // Repositories
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remoteDataSource: sl(), locationDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetNearbyEventsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventsForMapBoundsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventByIdUseCase(sl()));
  sl.registerLazySingleton(() => RecordEventViewUseCase(sl()));

  // BLoCs (Factory)
  sl.registerFactory(
    () => HomeBloc(
      getNearbyEvents: sl(),
      getEventsForMapBounds: sl(),
      tileProvider: sl(),
    ),
  );

  // ========================================
  // FEATURE: PROFILE
  // ========================================

  // DataSources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl(), secureStorage: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowedPromotersUseCase(sl()));
  sl.registerLazySingleton(() => GetBlockedPromotersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMyProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAvatarUseCase(sl()));

  // BLoC (Singleton - compartido en toda la app)
  sl.registerLazySingleton(
    () => ProfileBloc(
      getMyProfile: sl(),
      updateMyProfile: sl(),
      uploadAvatar: sl(),
      deleteAvatar: sl(),
      prefs: sl(),
    ),
  );

  // ========================================
  // FEATURE: PROMOTER PROFILE
  // ========================================

  // DataSources
  sl.registerLazySingleton<PromoterRemoteDataSource>(
    () => PromoterRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PromoterRepository>(
    () => PromoterRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetPromoterProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetPromoterEventsUseCase(sl()));

  // ========================================
  // FEATURE: USER ACTIONS
  // ========================================

  // DataSources
  sl.registerLazySingleton<UserActionsRemoteDataSource>(
    () => UserActionsRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<UserActionsRepository>(
    () => UserActionsRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => AddEventToFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => RemoveEventFromFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => FollowPromoterUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowPromoterUseCase(sl()));
  sl.registerLazySingleton(() => BlockUserUseCase(sl()));
  sl.registerLazySingleton(() => UnblockUserUseCase(sl()));

  // ========================================
  // FEATURE: PREFERENCES
  // ========================================

  // DataSources
  sl.registerLazySingleton<PreferencesRemoteDataSource>(
    () => PreferencesRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetPreferencesUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePreferencesUseCase(sl()));

  // ========================================
  // FEATURE: NOTIFICATIONS
  // ========================================

  // DataSources
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAllNotificationsUseCase(sl()));

  // BLoC (Singleton — shared across toolbar, profile and notifications page)
  sl.registerLazySingleton(
    () => NotificationsBloc(
      getNotifications: sl(),
      getUnreadCount: sl(),
      markNotificationRead: sl(),
      markAllNotificationsRead: sl(),
      deleteNotification: sl(),
      deleteAllNotifications: sl(),
    ),
  );

  // ========================================
  // FEATURE: REPORTS
  // ========================================
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton(() => CreateReportUseCase(sl()));

  // ========================================
  // SERVICE: BLOCKED USERS
  // ========================================
  sl.registerLazySingleton(
    () => BlockedUsersService(dataSource: sl<UserActionsRemoteDataSource>()),
  );

  // ========================================
  // AUTH: T&C USECASES
  // ========================================
  sl.registerLazySingleton(() => GetTermsInfoUseCase(sl()));
  sl.registerLazySingleton(() => AcceptTermsUseCase(sl()));
  sl.registerLazySingleton(() => GetLegalDocumentUseCase(sl()));
}
