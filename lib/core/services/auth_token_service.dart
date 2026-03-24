// lib/core/services/auth_token_service.dart

/// Servicio singleton para almacenar el accessToken exclusivamente en memoria.
///
/// El accessToken NUNCA se persiste en disco. Solo vive mientras la app está
/// activa. Al relanzar la app, el interceptor Dio detectará un 401, usará el
/// refreshToken (que sí está en flutter_secure_storage) y obtendrá un nuevo
/// accessToken, almacenándolo de nuevo aquí.
class AuthTokenService {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void clear() {
    _accessToken = null;
  }
}
