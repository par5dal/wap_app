// lib/core/validators/validators.dart

// Puedes pasarle las traducciones para que los mensajes de error también se internacionalicen.
import 'package:wap_app/l10n/app_localizations.dart';

class Validators {
  static String? email(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.validatorRequired; // "Este campo es requerido"
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return t.validatorInvalidEmail; // "Formato de email inválido"
    }
    return null; // `null` significa que la validación es correcta.
  }

  static String? password(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.validatorRequired;
    }
    if (value.length < 8) {
      return t.validatorPasswordLength; // "La contraseña debe tener al menos 8 caracteres"
    }
    return null;
  }
}