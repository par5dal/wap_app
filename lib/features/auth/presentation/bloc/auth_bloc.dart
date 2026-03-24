// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:io';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/auth/domain/usecases/login_user.dart';
import 'package:wap_app/features/auth/domain/usecases/register_user.dart';
import 'package:wap_app/features/auth/domain/usecases/get_google_auth_url.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:wap_app/features/auth/domain/usecases/get_apple_auth_url.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_apple.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/usecases/check_email_exists.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUserUseCase registerUser;
  final GetGoogleAuthUrlUseCase getGoogleAuthUrl;
  final LoginWithGoogleCallbackUseCase loginWithGoogleCallback;
  final GetAppleAuthUrlUseCase getAppleAuthUrl;
  final LoginWithAppleCallbackUseCase loginWithAppleCallback;
  final CheckEmailExistsUseCase checkEmailExists;
  final AppBloc appBloc;
  final SharedPreferences prefs;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.getGoogleAuthUrl,
    required this.loginWithGoogleCallback,
    required this.getAppleAuthUrl,
    required this.loginWithAppleCallback,
    required this.checkEmailExists,
    required this.appBloc,
    required this.prefs,
  }) : super(AuthFormInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
    on<GoogleSignInPressed>(_onGoogleSignInPressed);
    on<GoogleCallbackReceived>(_onGoogleCallbackReceived);
    on<AppleSignInPressed>(_onAppleSignInPressed);
    on<AppleCallbackReceived>(_onAppleCallbackReceived);
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
    // firstName/lastName se envían al datasource, que llama a POST /users/profile internamente.
    final result = await registerUser(
      RegisterParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );
    result.fold(
      (failure) {
        // Supabase con confirmación de email activa: el backend no puede crear sesión
        // hasta que el usuario confirme su correo. Detectar ese caso específico.
        final msg = failure.message.toLowerCase();
        if (msg.contains('session') ||
            msg.contains('email') ||
            msg.contains('confirm')) {
          emit(AuthRegisterEmailVerificationRequired(event.email));
        } else {
          emit(AuthFormFailure(failure.message));
        }
      },
      (token) {
        _saveAuthProvider(token);
        // El perfil ya se creó en el datasource (POST /users/profile).
        // Los nuevos usuarios nunca han aceptado T&C → mostrar pantalla de aceptación.
        appBloc.add(const AppTermsNotAccepted(requiredVersion: ''));
        emit(AuthFormSuccess());
      },
    );
  }

  Future<void> _onGoogleSignInPressed(
    GoogleSignInPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    try {
      final locale = Platform.localeName;
      final lang = locale.split('_').first;

      final result = await getGoogleAuthUrl(lang: lang);

      // Extraer el resultado de forma imperativa para evitar async dentro de fold
      // (fold no await callbacks async → emit se llamaría sobre un handler ya completado)
      String? url;
      String? errorMsg;
      result.fold((failure) => errorMsg = failure.message, (u) => url = u);

      if (errorMsg != null) {
        emit(AuthFormFailure(errorMsg!));
        return;
      }

      final uri = Uri.parse(url!);
      if (await canLaunchUrl(uri)) {
        final mode = LaunchMode.inAppBrowserView;
        try {
          await launchUrl(uri, mode: mode);
        } on PlatformException catch (e) {
          // iOS SFSafariViewController lanza PlatformException al redirigir a wap://
          // una vez completado el OAuth. Es esperado: app_links ya interceptó el deep
          // link y completó el login. No emitir error.
          AppLogger.info(
            'ℹ️ PlatformException OAuth Google (esperado en iOS): ${e.message}',
          );
          return;
        }
        // Resetear loading: si el usuario completa el flujo llegará GoogleCallbackReceived,
        // si cierra el navegador sin autenticar simplemente volvemos al estado inicial.
        if (!emit.isDone) emit(AuthFormInitial());
      } else {
        emit(
          const AuthFormFailure('No se pudo abrir el navegador para Google.'),
        );
      }
    } catch (e) {
      AppLogger.error('Error opening Google auth URL', e, StackTrace.current);
      if (!emit.isDone) {
        emit(AuthFormFailure('Error al iniciar sesión con Google: $e'));
      }
    }
  }

  Future<void> _onGoogleCallbackReceived(
    GoogleCallbackReceived event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    try {
      final locale = Platform.localeName;
      final lang = locale.split('_').first;

      final result = await loginWithGoogleCallback(
        GoogleCallbackParams(
          supabaseAccessToken: event.supabaseAccessToken,
          supabaseRefreshToken: event.supabaseRefreshToken,
          lang: lang,
        ),
      );

      result.fold((failure) => emit(AuthFormFailure(failure.message)), (token) {
        _saveAuthProvider(token);
        appBloc.add(
          const AppAuthStatusChanged(
            AuthStatus.authenticated,
            method: 'google',
          ),
        );
        if (token.isNewUser) {
          emit(AuthFormSuccessNewUser());
        } else if (token.user?.profileComplete == false) {
          emit(AuthFormSuccessProfileIncomplete());
        } else {
          emit(AuthFormSuccess());
        }
      });
    } catch (e) {
      AppLogger.error('Error in Google callback', e, StackTrace.current);
      emit(
        AuthFormFailure(
          'Error al completar el inicio de sesión con Google: $e',
        ),
      );
    }
  }

  Future<void> _onAppleSignInPressed(
    AppleSignInPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    try {
      final locale = Platform.localeName;
      final lang = locale.split('_').first;

      final result = await getAppleAuthUrl(lang: lang);

      // Extraer el resultado de forma imperativa (mismo patrón que Google)
      String? url;
      String? errorMsg;
      result.fold((failure) => errorMsg = failure.message, (u) => url = u);

      if (errorMsg != null) {
        emit(AuthFormFailure(errorMsg!));
        return;
      }

      final uri = Uri.parse(url!);
      if (await canLaunchUrl(uri)) {
        final mode = LaunchMode.inAppBrowserView;
        try {
          await launchUrl(uri, mode: mode);
        } on PlatformException catch (e) {
          // iOS SFSafariViewController lanza PlatformException al redirigir a wap://
          // una vez completado el OAuth. Es esperado: app_links ya interceptó el deep
          // link y completó el login. No emitir error.
          AppLogger.info(
            'ℹ️ PlatformException OAuth Apple (esperado en iOS): ${e.message}',
          );
          return;
        }
        if (!emit.isDone) emit(AuthFormInitial());
      } else {
        emit(
          const AuthFormFailure('No se pudo abrir el navegador para Apple.'),
        );
      }
    } catch (e) {
      AppLogger.error('Error opening Apple auth URL', e, StackTrace.current);
      if (!emit.isDone) {
        emit(AuthFormFailure('Error al iniciar sesión con Apple: $e'));
      }
    }
  }

  Future<void> _onAppleCallbackReceived(
    AppleCallbackReceived event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFormLoading());
    try {
      final locale = Platform.localeName;
      final lang = locale.split('_').first;

      final result = await loginWithAppleCallback(
        AppleCallbackParams(
          supabaseAccessToken: event.supabaseAccessToken,
          supabaseRefreshToken: event.supabaseRefreshToken,
          lang: lang,
        ),
      );

      result.fold((failure) => emit(AuthFormFailure(failure.message)), (token) {
        _saveAuthProvider(token);
        appBloc.add(
          const AppAuthStatusChanged(AuthStatus.authenticated, method: 'apple'),
        );
        if (token.isNewUser) {
          emit(AuthFormSuccessNewUser());
        } else if (token.user?.profileComplete == false) {
          emit(AuthFormSuccessProfileIncomplete());
        } else {
          emit(AuthFormSuccess());
        }
      });
    } catch (e) {
      AppLogger.error('Error in Apple callback', e, StackTrace.current);
      emit(
        AuthFormFailure('Error al completar el inicio de sesión con Apple: $e'),
      );
    }
  }

  void _saveAuthProvider(TokenEntity token) {
    prefs.setString(
      'cached_auth_provider',
      token.user?.authProvider ?? 'email',
    );
  }
}
