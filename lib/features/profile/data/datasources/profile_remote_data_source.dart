// lib/features/profile/data/datasources/profile_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/constants/api_constants.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/features/profile/data/models/profile_model.dart';
import 'package:wap_app/features/profile/data/models/followed_promoter_model.dart';
import 'package:wap_app/features/profile/data/models/blocked_promoter_model.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ProfileRemoteDataSource {
  Future<UserWithProfileEntity> getMyProfile();
  Future<ProfileEntity> updateMyProfile(Map<String, dynamic> profileData);
  Future<Map<String, dynamic>> getUploadSignature({
    required String preset,
    required String uploadType,
    String? eventId,
    String? transformation,
  });
  Future<void> deleteResource(String url);
  Future<List<FollowedPromoterModel>> getFollowedPromoters({int limit = 50});
  Future<List<BlockedPromoterModel>> getBlockedPromotersFull({int limit = 50});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ProfileRemoteDataSourceImpl({required this.dio, required this.secureStorage});

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final message = e.response!.data['message'];

      if (message is List) {
        return message.join('\n');
      }
      if (message is String) {
        return message;
      }
    }
    return 'Error de comunicación con el servidor.';
  }

  @override
  Future<UserWithProfileEntity> getMyProfile() async {
    try {
      final response = await dio.get(ApiConstants.myProfileEndpoint);

      // ✅ Aceptar tanto 200 (OK) como 304 (Not Modified)
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data as Map<String, dynamic>;

        // El backend devuelve el perfil en el root y el usuario en 'user'
        final userData = data['user'] as Map<String, dynamic>;

        // Extraer datos del perfil del root (excluyendo 'user')
        final profileData = Map<String, dynamic>.from(data)..remove('user');

        // Crear ProfileModel desde profileData
        final profileModel = ProfileModel.fromJson(profileData);

        // Crear UserWithProfileEntity
        return UserWithProfileEntity(
          id: userData['id'] as String,
          email: userData['email'] as String,
          role: userData['role'] as String?,
          isActive: userData['is_active'] as bool?,
          createdAt: DateTime.parse(userData['created_at'] as String),
          updatedAt: DateTime.parse(userData['updated_at'] as String),
          profile: profileModel.toEntity(),
        );
      } else {
        throw ServerException(
          message: 'Error inesperado del servidor',
          statusCode: response.statusCode,
          code: 'unexpected_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'get_profile_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        message: 'Error inesperado al obtener perfil',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProfileEntity> updateMyProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      // Filtrar valores nulos y vacíos, EXCEPTO avatar_url que puede ser null explícitamente
      final cleanData = Map<String, dynamic>.from(profileData)
        ..removeWhere(
          (key, value) => (value == null && key != 'avatar_url') || value == '',
        );

      final response = await dio.patch(
        ApiConstants.myProfileEndpoint,
        data: cleanData,
      ); // ✅ Aceptar tanto 200 (OK) como 304 (Not Modified)
      if (response.statusCode == 200 || response.statusCode == 304) {
        final model = ProfileModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return model.toEntity();
      } else {
        throw ServerException(
          message: 'Error inesperado del servidor',
          statusCode: response.statusCode,
          code: 'unexpected_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'update_profile_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        message: 'Error inesperado al actualizar perfil',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUploadSignature({
    required String preset,
    required String uploadType,
    String? eventId,
    String? transformation,
  }) async {
    try {
      final body = <String, dynamic>{
        'preset': preset,
        'uploadType': uploadType,
        if (eventId != null) 'eventId': eventId,
        if (transformation != null) 'transformation': transformation,
      };

      final response = await dio.post(
        ApiConstants.uploadSignatureEndpoint,
        data: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'signature': response.data['signature'] as String,
          'timestamp': response.data['timestamp'] as int,
          'api_key': response.data['api_key'] as String,
          'folder': response.data['folder'] as String? ?? '',
          if (response.data['cloud_name'] != null)
            'cloud_name': response.data['cloud_name'] as String,
        };
      } else {
        throw ServerException(
          message: 'Error al obtener firma de subida',
          statusCode: response.statusCode,
          code: 'signature_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message:
            'Error de conexión al subir imagen: ${_extractErrorMessage(e)}',
        statusCode: e.response?.statusCode,
        code: 'signature_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        message: 'Error inesperado al obtener firma: ${e.toString()}',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteResource(String url) async {
    try {
      final response = await dio.delete(
        ApiConstants.deleteResourceEndpoint,
        data: {'url': url},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ServerException(
          message: 'Error al eliminar recurso',
          statusCode: response.statusCode,
          code: 'delete_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'delete_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<FollowedPromoterModel>> getFollowedPromoters({
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/promoters/following/list',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final Map<String, dynamic> responseData = response.data ?? {'data': []};
        final List<dynamic> data = responseData['data'] ?? [];

        return data
            .map(
              (json) =>
                  FollowedPromoterModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw ServerException(
          message: 'Error al obtener promotores seguidos',
          statusCode: response.statusCode,
          code: 'get_following_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      // Si el endpoint retorna 204 No Content o está vacío, retornar lista vacía
      if (e.response?.statusCode == 204 ||
          (e.response?.statusCode == 200 && e.response?.data == null)) {
        return [];
      }

      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'get_following_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        message: 'Error inesperado al obtener promotores seguidos',
        code: 'get_following_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<BlockedPromoterModel>> getBlockedPromotersFull({
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/users/me/blocked',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final Map<String, dynamic> responseData =
            response.data ?? {'blocked': []};
        final List<dynamic> data = responseData['blocked'] ?? [];

        return data
            .map(
              (json) =>
                  BlockedPromoterModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw ServerException(
          message: 'Error al obtener promotores bloqueados',
          statusCode: response.statusCode,
          code: 'get_blocked_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 204 ||
          (e.response?.statusCode == 200 && e.response?.data == null)) {
        return [];
      }

      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'get_blocked_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        message: 'Error inesperado al obtener promotores bloqueados',
        code: 'get_blocked_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
