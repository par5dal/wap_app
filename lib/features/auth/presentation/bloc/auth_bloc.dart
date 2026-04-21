// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/auth/domain/usecases/login_user.dart';
import 'package:wap_app/features/auth/domain/usecases/register_user.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_apple.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/usecases/check_email_exists.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUserUseCase registerUser;
  final LoginWithGoogleUseCase loginWithGoogle;
  final LoginWithAppleUseCase loginWithApple;
  final CheckEmailExistsUseCase checkEmailExists;
  final AppBloc appBloc;
  final SharedPreferences prefs;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.loginWithGoogle,
    required this.loginWithApple,
    required this.checkEmailExists,
    required this.appBloc,
    required this.prefs,
  }) : super(AuthFormInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
    on<GoogleSignInPressed>(_onGoogleSignInPressed);
    on<AppleSignInPressed>(_onAppleSignInPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    final result = await loginUser(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold((failure) => emit(AuthFormFailure(failure.message)), (token) {
      _saveAuthProvider(token);
      appBloc.add(
        const AppAuthStatusChanged(AuthStatus.authenticated, method: 'email'),
      );
      emit(AuthFormSuccess());
    });
  }

  Future<void> _onRegisterButtonPressed(
    RegisterButtonPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    final result = await registerUser(
      RegisterParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role,
      ),
    );
    result.fold((failure) => emit(AuthFormFailure(failure.message)), (token) {
      _saveAuthProvider(token);
      // Los nuevos usuarios nunca han aceptado T&C → mostrar pantalla de aceptación.
      appBloc.add(const AppTermsNotAccepted(requiredVersion: ''));
      emit(AuthFormSuccess());
    });
  }

  Future<void> _onGoogleSignInPressed(
    GoogleSignInPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    try {
      final result = await loginWithGoogle();
      result.fold(
        (failure) {
          if (!emit.isDone) emit(AuthFormFailure(failure.message));
        },
        (token) {
          _saveAuthProvider(token);
          if (token.isNewUser) {
            appBloc.add(const AppTermsNotAccepted(requiredVersion: ''));
          } else if (token.user?.profileComplete == false) {
            appBloc.add(
              const AppAuthStatusChanged(
                AuthStatus.authenticated,
                method: 'google',
              ),
            );
            if (!emit.isDone) emit(AuthFormSuccessProfileIncomplete());
            return;
          } else {
            appBloc.add(
              const AppAuthStatusChanged(
                AuthStatus.authenticated,
                method: 'google',
              ),
            );
          }
          if (!emit.isDone) emit(AuthFormSuccess());
        },
      );
    } catch (e) {
      AppLogger.error('Error en Google Sign-In', e, StackTrace.current);
      if (!emit.isDone) {
        emit(AuthFormFailure('Error al iniciar sesión con Google: $e'));
      }
    }
  }

  Future<void> _onAppleSignInPressed(
    AppleSignInPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    try {
      final result = await loginWithApple();
      result.fold(
        (failure) {
          if (!emit.isDone) emit(AuthFormFailure(failure.message));
        },
        (token) {
          _saveAuthProvider(token);
          if (token.isNewUser) {
            appBloc.add(const AppTermsNotAccepted(requiredVersion: ''));
          } else if (token.user?.profileComplete == false) {
            appBloc.add(
              const AppAuthStatusChanged(
                AuthStatus.authenticated,
                method: 'apple',
              ),
            );
            if (!emit.isDone) emit(AuthFormSuccessProfileIncomplete());
            return;
          } else {
            appBloc.add(
              const AppAuthStatusChanged(
                AuthStatus.authenticated,
                method: 'apple',
              ),
            );
          }
          if (!emit.isDone) emit(AuthFormSuccess());
        },
      );
    } catch (e) {
      AppLogger.error('Error en Apple Sign-In', e, StackTrace.current);
      if (!emit.isDone) {
        emit(AuthFormFailure('Error al iniciar sesión con Apple: $e'));
      }
    }
  }

  void _saveAuthProvider(TokenEntity token) {
    prefs.setString(
      'cached_auth_provider',
      token.user?.authProvider ?? 'email',
    );
    if (token.user?.role != null) {
      prefs.setString('user_role', token.user!.role);
    }
  }
}
