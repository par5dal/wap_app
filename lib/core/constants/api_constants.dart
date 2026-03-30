// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';

  // Firebase Auth — el backend intercambia el ID token de Firebase por datos del perfil
  static const String sessionEndpoint = '/auth/session';

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
