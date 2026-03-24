// lib/core/services/app_version_service.dart

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  final Dio _dio;

  AppVersionService({required Dio dio}) : _dio = dio;

  /// Compares the installed app version against the backend's [min_version].
  /// Returns [true] if the installed version is strictly older and an update
  /// must be forced.  Returns [false] on any error (network, parsing) so that
  /// connectivity issues never block the user.
  Future<bool> isUpdateRequired() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/app/config');
      final data = response.data;
      if (data == null) return false;

      final minVersionStr = data['min_version'] as String?;
      if (minVersionStr == null || minVersionStr.isEmpty) return false;

      final packageInfo = await PackageInfo.fromPlatform();
      final installedStr = packageInfo.version; // e.g. "1.2.0"

      return _isOlderThan(installedStr, minVersionStr);
    } catch (_) {
      // Fail silently: network errors, malformed JSON, etc.
      return false;
    }
  }

  /// Returns true if [installed] is strictly older than [minimum].
  /// Both strings must be dot-separated integers (semver: major.minor.patch).
  static bool _isOlderThan(String installed, String minimum) {
    final a = _toInts(installed);
    final b = _toInts(minimum);

    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av < bv) return true;
      if (av > bv) return false;
    }
    return false; // equal → no update needed
  }

  static List<int> _toInts(String version) =>
      version.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
}
