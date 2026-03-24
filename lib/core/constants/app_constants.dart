// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 8);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheValidDuration = Duration(minutes: 30);

  // Map
  static const double defaultZoom = 14.0;
  static const double maxSearchRadius = 50.0; // km

  // Images
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const int maxImageSizeKB = 5120; // 5MB
}
