// lib/core/config/env_config.dart
//
// Entorno activo determinado en tiempo de compilación mediante:
//   --dart-define=ENV=development   (local, ver .vscode/launch.json)
//   --dart-define=ENV=production    (CI / GitHub Actions)
//
// Valor por defecto: 'development' para que `flutter run` sin flags
// funcione en local apuntando siempre al entorno de desarrollo.

// ignore_for_file: constant_identifier_names

const _env = String.fromEnvironment('ENV', defaultValue: 'development');

class EnvConfig {
  EnvConfig._();

  /// true si se compiló con --dart-define=ENV=production
  static const bool isProduction = _env == 'production';

  /// Sufijo para seleccionar la variable correcta del .env ('PROD' | 'DEV')
  static const String suffix = isProduction ? 'PROD' : 'DEV';
}
