// test/presentation/bloc/app_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/services/analytics_service.dart';
import 'package:wap_app/core/services/app_version_service.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/core/services/notification_service.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/presentation/bloc/locale/locale_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockLocaleCubit extends Mock implements LocaleCubit {}

class MockBlockedUsersService extends Mock implements BlockedUsersService {}

class MockAppVersionService extends Mock implements AppVersionService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AppBloc bloc;
  late MockAuthRepository mockAuthRepository;
  late MockNotificationService mockNotificationService;
  late MockAnalyticsService mockAnalyticsService;
  late MockLocaleCubit mockLocaleCubit;
  late MockBlockedUsersService mockBlockedUsersService;
  late MockAppVersionService mockAppVersionService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockNotificationService = MockNotificationService();
    mockAnalyticsService = MockAnalyticsService();
    mockLocaleCubit = MockLocaleCubit();
    mockBlockedUsersService = MockBlockedUsersService();
    mockAppVersionService = MockAppVersionService();
    mockSharedPreferences = MockSharedPreferences();

    // Register mocks used via sl<> inside AppBloc
    final sl = GetIt.instance;
    if (!sl.isRegistered<AnalyticsService>()) {
      sl.registerSingleton<AnalyticsService>(mockAnalyticsService);
    }
    if (!sl.isRegistered<LocaleCubit>()) {
      sl.registerSingleton<LocaleCubit>(mockLocaleCubit);
    }
    if (!sl.isRegistered<BlockedUsersService>()) {
      sl.registerSingleton<BlockedUsersService>(mockBlockedUsersService);
    }
    if (!sl.isRegistered<AppVersionService>()) {
      sl.registerSingleton<AppVersionService>(mockAppVersionService);
    }
    if (!sl.isRegistered<SharedPreferences>()) {
      sl.registerSingleton<SharedPreferences>(mockSharedPreferences);
    }

    // Stub all fire-and-forget calls
    when(
      () => mockNotificationService.registerToken(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.unregisterToken(),
    ).thenAnswer((_) async {});
    when(
      () => mockAnalyticsService.logLogin(method: any(named: 'method')),
    ).thenAnswer((_) async {});
    when(() => mockAnalyticsService.logLogout()).thenAnswer((_) async {});
    when(() => mockLocaleCubit.resetToDevice()).thenAnswer((_) async {});
    when(
      () => mockBlockedUsersService.loadFromRemote(),
    ).thenAnswer((_) async {});
    when(() => mockBlockedUsersService.clear()).thenAnswer((_) {});
    when(
      () => mockAuthRepository.checkUserStatus(),
    ).thenAnswer((_) async => const Right(null));
    // Default: no forced update needed
    when(
      () => mockAppVersionService.isUpdateRequired(),
    ).thenAnswer((_) async => false);
    when(
      () => mockSharedPreferences.remove(any()),
    ).thenAnswer((_) async => true);

    bloc = AppBloc(
      authRepository: mockAuthRepository,
      notificationService: mockNotificationService,
      checkAuthSession: () async => false,
    );
  });

  tearDown(() {
    bloc.close();
    GetIt.instance.reset();
  });

  group('AppStatusChecked', () {
    blocTest<AppBloc, AppState>(
      'emits [authenticated] when session exists',
      build: () => AppBloc(
        authRepository: mockAuthRepository,
        notificationService: mockNotificationService,
        checkAuthSession: () async => true,
      ),
      act: (b) => b.add(AppStatusChecked()),
      expect: () => [const AppState.authenticated()],
    );

    blocTest<AppBloc, AppState>(
      'emits [unauthenticated] when no session',
      build: () => AppBloc(
        authRepository: mockAuthRepository,
        notificationService: mockNotificationService,
        checkAuthSession: () async => false,
      ),
      act: (b) => b.add(AppStatusChecked()),
      expect: () => [const AppState.unauthenticated()],
    );

    blocTest<AppBloc, AppState>(
      'emits [unauthenticated] when auth check throws',
      build: () => AppBloc(
        authRepository: mockAuthRepository,
        notificationService: mockNotificationService,
        checkAuthSession: () async => throw Exception('Auth check failed'),
      ),
      act: (b) => b.add(AppStatusChecked()),
      expect: () => [const AppState.unauthenticated()],
    );
  });

  group('AppAuthStatusChanged', () {
    blocTest<AppBloc, AppState>(
      'emits [authenticated] and registers FCM token on login',
      build: () => bloc,
      act: (b) => b.add(
        const AppAuthStatusChanged(AuthStatus.authenticated, method: 'email'),
      ),
      expect: () => [const AppState.authenticated()],
      verify: (_) {
        verify(() => mockNotificationService.registerToken()).called(1);
        verify(() => mockAnalyticsService.logLogin(method: 'email')).called(1);
      },
    );

    blocTest<AppBloc, AppState>(
      'emits [unauthenticated] and resets locale on logout event',
      build: () => bloc,
      act: (b) => b.add(const AppAuthStatusChanged(AuthStatus.unauthenticated)),
      expect: () => [const AppState.unauthenticated()],
      verify: (_) {
        verify(() => mockLocaleCubit.resetToDevice()).called(1);
      },
    );
  });

  group('AppLogoutRequested', () {
    blocTest<AppBloc, AppState>(
      'emits [unauthenticated], unregisters FCM and calls logout',
      build: () {
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(AppLogoutRequested()),
      expect: () => [const AppState.unauthenticated()],
      verify: (_) {
        verify(() => mockNotificationService.unregisterToken()).called(1);
        verify(() => mockAuthRepository.logout()).called(1);
        verify(() => mockAnalyticsService.logLogout()).called(1);
      },
    );
  });

  group('AppTermsNotAccepted', () {
    blocTest<AppBloc, AppState>(
      'emits [termsNotAccepted] with the required version',
      build: () => bloc,
      act: (b) => b.add(const AppTermsNotAccepted(requiredVersion: '1.2')),
      expect: () => [const AppState.termsNotAccepted(version: '1.2')],
    );

    blocTest<AppBloc, AppState>(
      'preserves version string in state',
      build: () => bloc,
      act: (b) => b.add(const AppTermsNotAccepted(requiredVersion: '2.0')),
      expect: () => [const AppState.termsNotAccepted(version: '2.0')],
    );
  });

  group('AppAccountSuspended', () {
    blocTest<AppBloc, AppState>(
      'emits [suspended] with reason',
      build: () => bloc,
      act: (b) =>
          b.add(const AppAccountSuspended(reason: 'Violación de términos')),
      expect: () => [const AppState.suspended(reason: 'Violación de términos')],
    );

    blocTest<AppBloc, AppState>(
      'emits [suspended] without reason',
      build: () => bloc,
      act: (b) => b.add(const AppAccountSuspended()),
      expect: () => [const AppState.suspended()],
    );
  });

  group('Force update (AppVersionService)', () {
    blocTest<AppBloc, AppState>(
      'emits [updateRequired] when isUpdateRequired returns true',
      build: () {
        when(
          () => mockAppVersionService.isUpdateRequired(),
        ).thenAnswer((_) async => true);
        return bloc;
      },
      act: (b) => b.add(AppStatusChecked()),
      expect: () => [const AppState.updateRequired()],
    );

    blocTest<AppBloc, AppState>(
      'does not check auth when update is required',
      build: () {
        when(
          () => mockAppVersionService.isUpdateRequired(),
        ).thenAnswer((_) async => true);
        return AppBloc(
          authRepository: mockAuthRepository,
          notificationService: mockNotificationService,
          checkAuthSession: () async => true,
        );
      },
      act: (b) => b.add(AppStatusChecked()),
      // Only [updateRequired] — no [authenticated] — proves auth check was skipped.
      expect: () => [const AppState.updateRequired()],
    );

    blocTest<AppBloc, AppState>(
      'proceeds to auth check when isUpdateRequired returns false',
      build: () {
        when(
          () => mockAppVersionService.isUpdateRequired(),
        ).thenAnswer((_) async => false);
        return AppBloc(
          authRepository: mockAuthRepository,
          notificationService: mockNotificationService,
          checkAuthSession: () async => false,
        );
      },
      act: (b) => b.add(AppStatusChecked()),
      expect: () => [const AppState.unauthenticated()],
    );
  });

  group('BlockedUsersService side effects', () {
    blocTest<AppBloc, AppState>(
      'loads blocked users when session exists on AppStatusChecked',
      build: () => AppBloc(
        authRepository: mockAuthRepository,
        notificationService: mockNotificationService,
        checkAuthSession: () async => true,
      ),
      act: (b) => b.add(AppStatusChecked()),
      expect: () => [const AppState.authenticated()],
      verify: (_) {
        verify(() => mockBlockedUsersService.loadFromRemote()).called(1);
      },
    );

    blocTest<AppBloc, AppState>(
      'loads blocked users on AppAuthStatusChanged(authenticated)',
      build: () => bloc,
      act: (b) => b.add(
        const AppAuthStatusChanged(AuthStatus.authenticated, method: 'google'),
      ),
      expect: () => [const AppState.authenticated()],
      verify: (_) {
        verify(() => mockBlockedUsersService.loadFromRemote()).called(1);
      },
    );

    blocTest<AppBloc, AppState>(
      'clears blocked users on AppLogoutRequested',
      build: () {
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(AppLogoutRequested()),
      expect: () => [const AppState.unauthenticated()],
      verify: (_) {
        verify(() => mockBlockedUsersService.clear()).called(1);
      },
    );
  });
}
