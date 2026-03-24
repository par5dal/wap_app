// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Google OAuth — flujo backend completo
  // GET  /auth/google/login?lang=es&role=CONSUMER  → devuelve {url: '...'}
  static const String googleGetUrlEndpoint = '/auth/google/login';
  // POST /auth/google/callback {accessToken, refreshToken, lang, role?}
  static const String googleCallbackEndpoint = '/auth/google/callback';

  // Apple OAuth — mismo flujo que Google
  // GET  /auth/apple/login?lang=es&role=CONSUMER  → devuelve {url: '...'}
  static const String appleGetUrlEndpoint = '/auth/apple/login';
  // POST /auth/apple/callback {accessToken, refreshToken, lang, role?}
  static const String appleCallbackEndpoint = '/auth/apple/callback';

  static const String searchEventsEndpoint = '/events/search';
  static const String getCategoriesEndpoint = '/categories';
  static const String checkEmailExistsEndpoint = '/auth/check-email';

  // PROFILE ENDPOINTS
  static const String createProfileEndpoint =
      '/users/profile'; // POST tras registro
  static const String myProfileEndpoint =
      '/users/me/profile'; // GET/PATCH sesión

  // UPLOADS ENDPOINTS
  static const String uploadSignatureEndpoint = '/uploads/signature';
  static const String deleteResourceEndpoint = '/uploads/resource';

  // TERMS & CONDITIONS ENDPOINTS
  static const String termsInfoEndpoint = '/auth/terms-info';
  static const String acceptTermsEndpoint = '/auth/accept-terms';

  // USER BLOCK ENDPOINTS (se usan con interpolación: /users/:id/block)
  static const String blockedUsersEndpoint = '/users/me/blocked';
}
