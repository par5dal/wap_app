// lib/presentation/bloc/locale/locale_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

/// Gestiona el locale activo de la app.
///
/// Estado null → usar el idioma del dispositivo (comportamiento por defecto).
/// Estado Locale('es') / Locale('en') / Locale('pt') → forzar ese idioma.
///
/// Solo los usuarios autenticados pueden cambiar el locale.
/// Los no autenticados siempre usan el del dispositivo (null).
class LocaleCubit extends Cubit<Locale?> {
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(null) {
    _loadLocale();
  }

  void _loadLocale() {
    final code = _prefs.getString(_localeKey);
    if (code != null) {
      emit(Locale(code));
    }
  }

  /// Cambia el idioma y lo persiste localmente.
  /// Llama esto SOLO cuando el usuario esté autenticado.
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
    emit(locale);
  }

  /// Restaura al idioma del dispositivo y borra la preferencia local.
  Future<void> resetToDevice() async {
    await _prefs.remove(_localeKey);
    emit(null);
  }
}
