// lib/features/user_actions/data/datasources/user_actions_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';

abstract class UserActionsRemoteDataSource {
  // Favoritos
  Future<void> addEventToFavorites(String eventId);
  Future<void> removeEventFromFavorites(String eventId);

  // Seguir promotores
  Future<void> followPromoter(String promoterId);
  Future<void> unfollowPromoter(String promoterId);

  // Bloquear usuarios
  Future<List<String>> getBlockedUsers();
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
}

class UserActionsRemoteDataSourceImpl implements UserActionsRemoteDataSource {
  final Dio dio;

  UserActionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> addEventToFavorites(String eventId) async {
    try {
      final response = await dio.post('/events/$eventId/favorite');

      if (response.statusCode != 201) {
        throw ServerException(
          message: 'Error adding event to favorites',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in addEventToFavorites', e, null);
      if (e.response?.statusCode == 409) {
        // Event already in favorites - this is acceptable
        return;
      }
      if (e.response?.statusCode == 404) {
        throw ServerException(message: 'Event not found', statusCode: 404);
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in addEventToFavorites', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> removeEventFromFavorites(String eventId) async {
    try {
      final response = await dio.delete('/events/$eventId/favorite');

      if (response.statusCode != 204) {
        throw ServerException(
          message: 'Error removing event from favorites',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in removeEventFromFavorites', e, null);
      if (e.response?.statusCode == 404) {
        // Event not in favorites - this is acceptable
        return;
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in removeEventFromFavorites', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> followPromoter(String promoterId) async {
    try {
      final response = await dio.post('/promoters/$promoterId/follow');

      if (response.statusCode != 201) {
        throw ServerException(
          message: 'Error following promoter',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in followPromoter', e, null);
      if (e.response?.statusCode == 409) {
        // Already following - this is acceptable
        return;
      }
      if (e.response?.statusCode == 404) {
        throw ServerException(message: 'Promoter not found', statusCode: 404);
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in followPromoter', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unfollowPromoter(String promoterId) async {
    try {
      final response = await dio.delete('/promoters/$promoterId/follow');

      if (response.statusCode != 204) {
        throw ServerException(
          message: 'Error unfollowing promoter',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in unfollowPromoter', e, null);
      if (e.response?.statusCode == 404) {
        // Not following - this is acceptable
        return;
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in unfollowPromoter', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getBlockedUsers() async {
    try {
      final response = await dio.get('/users/me/blocked');
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 304) {
        final data = response.data;
        // 304 or empty body → nothing changed, return empty list
        if (data == null) return [];
        // Backend returns { "blocked": [ { "user": { "id": "..." }, ... } ] }
        final Map<String, dynamic> body = data is Map<String, dynamic>
            ? data
            : {};
        final List<dynamic> list = body['blocked'] as List<dynamic>? ?? [];
        return list
            .map((item) {
              final user = item['user'];
              if (user is Map) return user['id']?.toString() ?? '';
              return item['id']?.toString() ?? '';
            })
            .where((id) => id.isNotEmpty)
            .toList();
      }
      throw ServerException(
        message: 'Error getting blocked users',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getBlockedUsers', e, null);
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in getBlockedUsers', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    try {
      final response = await dio.post('/users/$userId/block');
      if (response.statusCode == 409) return; // Ya bloqueado, aceptable
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerException(
          message: 'Error blocking user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in blockUser', e, null);
      if (e.response?.statusCode == 409) return; // Ya bloqueado, aceptable
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in blockUser', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    try {
      final response = await dio.delete('/users/$userId/block');
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerException(
          message: 'Error unblocking user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in unblockUser', e, null);
      if (e.response?.statusCode == 404) {
        return; // No estaba bloqueado, aceptable
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in unblockUser', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }
}
