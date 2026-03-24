// lib/presentation/bloc/app/app_state.dart
part of 'app_bloc.dart';

// El estado global de autenticación de la app.
enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  termsNotAccepted,
  suspended,
  updateRequired,
}

class AppState extends Equatable {
  final AuthStatus status;
  final String? requiredTermsVersion;
  final String? suspendedReason;

  const AppState._({
    required this.status,
    this.requiredTermsVersion,
    this.suspendedReason,
  });

  // Estado inicial, mientras comprobamos la sesión.
  const AppState.unknown() : this._(status: AuthStatus.unknown);

  // Estado para cuando el usuario está logueado.
  const AppState.authenticated() : this._(status: AuthStatus.authenticated);

  // Estado para cuando el usuario no está logueado.
  const AppState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  // Estado cuando el usuario debe aceptar los T&C antes de continuar.
  const AppState.termsNotAccepted({required String version})
    : this._(
        status: AuthStatus.termsNotAccepted,
        requiredTermsVersion: version,
      );

  // Estado cuando la cuenta del usuario está suspendida.
  const AppState.suspended({String? reason})
    : this._(status: AuthStatus.suspended, suspendedReason: reason);

  // Estado cuando la versión instalada es inferior a la mínima requerida.
  const AppState.updateRequired() : this._(status: AuthStatus.updateRequired);

  @override
  List<Object?> get props => [status, requiredTermsVersion, suspendedReason];
}
