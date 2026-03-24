// lib/features/preferences/data/datasources/preferences_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/preferences/domain/entities/user_preferences.dart';

abstract class PreferencesRemoteDataSource {
  Future<UserPreferences> getPreferences();
  Future<UserPreferences> updatePreferences({required String lang});
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final Dio dio;
  PreferencesRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserPreferences> getPreferences() async {
    try {
      final response = await dio.get('/users/me/preferences');
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data as Map<String, dynamic>;
        return UserPreferences(lang: data['lang'] as String? ?? 'es');
      }
      throw ServerException(
        message: 'Error getting preferences',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getPreferences', e, e.stackTrace);
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e, st) {
      AppLogger.error('Error in getPreferences', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserPreferences> updatePreferences({required String lang}) async {
    try {
      final response = await dio.patch(
        '/users/me/preferences',
        data: {'lang': lang},
      );
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 304) {
        final data = response.data as Map<String, dynamic>;
        return UserPreferences(lang: data['lang'] as String? ?? lang);
      }
      throw ServerException(
        message: 'Error updating preferences',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in updatePreferences', e, e.stackTrace);
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e, st) {
      AppLogger.error('Error in updatePreferences', e, st);
      throw ServerException(message: e.toString());
    }
  }
}
