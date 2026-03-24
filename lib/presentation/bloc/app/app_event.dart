// lib/presentation/bloc/app/app_event.dart
part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
  @override
  List<Object> get props => [];
}

// Evento que se dispara al iniciar la app para comprobar el estado de la sesión.
class AppStatusChecked extends AppEvent {}

// Evento que se puede usar internamente para forzar un cambio de estado.
class AppAuthStatusChanged extends AppEvent {
  final AuthStatus status;
  final String? method; // 'email', 'google', 'apple'
  const AppAuthStatusChanged(this.status, {this.method});
  @override
  List<Object> get props => [status];
}

// Evento que se puede disparar desde la UI para cerrar la sesión del usuario.
class AppLogoutRequested extends AppEvent {}

// El backend rechazó la petición con 403 TERMS_NOT_ACCEPTED.
class AppTermsNotAccepted extends AppEvent {
  final String requiredVersion;
  const AppTermsNotAccepted({required this.requiredVersion});
  @override
  List<Object> get props => [requiredVersion];
}

// El backend rechazó la petición con 403 ACCOUNT_SUSPENDED.
class AppAccountSuspended extends AppEvent {
  final String? reason;
  const AppAccountSuspended({this.reason});
  @override
  List<Object> get props => [];
}
