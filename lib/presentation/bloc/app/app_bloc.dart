// lib/presentation/bloc/app/app_bloc.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/services/analytics_service.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/core/services/notification_service.dart';
import 'package:wap_app/core/services/app_version_service.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/presentation/bloc/locale/locale_cubit.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;
  final Future<bool> Function() _checkAuthSession;

  AppBloc({
    required AuthRepository authRepository,
    required NotificationService notificationService,
    Future<bool> Function()? checkAuthSession,
  }) : _authRepository = authRepository,
       _notificationService = notificationService,
       _checkAuthSession =
           checkAuthSession ??
           (() async => FirebaseAuth.instance.currentUser != null),
       super(const AppState.unknown()) {
    on<AppStatusChecked>(_onStatusChecked);
    on<AppAuthStatusChanged>(_onAuthStatusChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<AppTermsNotAccepted>(_onTermsNotAccepted);
    on<AppAccountSuspended>(_onAccountSuspended);
  }

  Future<void> _onStatusChecked(
    AppStatusChecked event,
    Emitter<AppState> emit,
  ) async {
    // ✅ Check mínima versión requerida antes de cualquier lógica de auth
    final isOutdated = await sl<AppVersionService>().isUpdateRequired();
    if (isOutdated) {
      emit(const AppState.updateRequired());
      return;
    }

    // ✅ Comprobar si hay sesión Firebase activa
    final bool hasLocalSession;
    try {
      hasLocalSession = await _checkAuthSession();
    } catch (_) {
      emit(const AppState.unauthenticated());
      return;
    }

    if (hasLocalSession) {
      // Verificar si el usuario tiene los T&C aceptados antes de ir a home.
      // Si el servidor devuelve 403 TERMS_NOT_ACCEPTED, el interceptor Dio
      // encola AppTermsNotAccepted automáticamente y no emitimos authenticated.
      final statusResult = await _authRepository.checkUserStatus();
      final isTermsNotAccepted = statusResult.fold(
        (failure) =>
            failure is ServerFailure && failure.code == 'TERMS_NOT_ACCEPTED',
        (_) => false,
      );

      if (isTermsNotAccepted) {
        // El interceptor ya habrá encolado AppTermsNotAccepted.
        // No emitimos authenticated para evitar mostrar home sin T&C aceptados.
        return;
      }

      emit(const AppState.authenticated());
      unawaited(_notificationService.registerToken());
      unawaited(sl<BlockedUsersService>().loadFromRemote());
    } else {
      // ✅ Permitir modo público (sin requerir login)
      emit(const AppState.unauthenticated());
    }
  }

  void _onAuthStatusChanged(
    AppAuthStatusChanged event,
    Emitter<AppState> emit,
  ) {
    emit(AppState._(status: event.status));
    if (event.status == AuthStatus.authenticated) {
      unawaited(
        sl<AnalyticsService>().logLogin(method: event.method ?? 'unknown'),
      );
      unawaited(_notificationService.registerToken());
      unawaited(sl<BlockedUsersService>().loadFromRemote());
    } else if (event.status == AuthStatus.unauthenticated) {
      unawaited(sl<LocaleCubit>().resetToDevice());
    }
  }

  Future<void> _onLogoutRequested(
    AppLogoutRequested event,
    Emitter<AppState> emit,
  ) async {
    // Desregistrar token FCM antes de limpiar las credenciales
    await _notificationService.unregisterToken();
    unawaited(sl<AnalyticsService>().logLogout());
    await _authRepository.logout();

    sl<BlockedUsersService>().clear();
    sl<SharedPreferences>().remove('user_role');
    emit(const AppState.unauthenticated());
  }

  void _onTermsNotAccepted(AppTermsNotAccepted event, Emitter<AppState> emit) {
    emit(AppState.termsNotAccepted(version: event.requiredVersion));
  }

  void _onAccountSuspended(AppAccountSuspended event, Emitter<AppState> emit) {
    emit(AppState.suspended(reason: event.reason));
  }
}
