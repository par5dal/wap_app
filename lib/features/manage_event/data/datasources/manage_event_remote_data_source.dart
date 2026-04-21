// lib/features/manage_event/data/datasources/manage_event_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/manage_event/domain/entities/category_entity.dart';
import 'package:wap_app/features/manage_event/domain/entities/saved_venue_entity.dart';
import 'package:wap_app/features/promoter_dashboard/data/models/my_event_model.dart';

abstract class ManageEventRemoteDataSource {
  Future<List<CategoryEntity>> getCategories();
  Future<List<SavedVenueEntity>> getMyVenues({int page = 1, int limit = 5});
  Future<MyEventModel> getEventById(String eventId);
  Future<String> createEvent(Map<String, dynamic> payload);
  Future<void> updateEvent(String eventId, Map<String, dynamic> payload);
  Future<void> submitEventForReview(String eventId);
  Future<void> unpublishEvent(String eventId);
  Future<Map<String, dynamic>> getUploadSignature({
    required String preset,
    String? eventId,
  });
}

class ManageEventRemoteDataSourceImpl implements ManageEventRemoteDataSource {
  final Dio dio;

  ManageEventRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final response = await dio.get(
        '/categories',
        queryParameters: {'page': 1, 'limit': 50},
      );
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
        final List<dynamic> items =
            (data is Map ? data['data'] : data) as List? ?? [];
        return items.map((json) {
          final j = json as Map<String, dynamic>;
          return CategoryEntity(
            id: j['id'] as String,
            name: j['name'] as String,
            slug: j['slug'] as String,
            svg: j['svg'] as String?,
            color: j['color'] as String?,
          );
        }).toList();
      }
      throw ServerException(
        message: 'Error fetching categories',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getCategories', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in getCategories', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<SavedVenueEntity>> getMyVenues({
    int page = 1,
    int limit = 5,
  }) async {
    try {
      final response = await dio.get(
        '/venues/my-venues',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data as Map<String, dynamic>;
        final items = data['data'] as List? ?? [];
        return items.map((json) {
          final j = json as Map<String, dynamic>;
          final loc = j['location'] as Map<String, dynamic>?;
          final coords = loc?['coordinates'] as List?;
          final lng = coords != null ? (coords[0] as num).toDouble() : 0.0;
          final lat = coords != null ? (coords[1] as num).toDouble() : 0.0;
          return SavedVenueEntity(
            id: j['id'] as String,
            name: j['name'] as String,
            address: j['address'] as String,
            lat: lat,
            lng: lng,
          );
        }).toList();
      }
      throw ServerException(
        message: 'Error fetching venues',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getMyVenues', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in getMyVenues', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MyEventModel> getEventById(String eventId) async {
    try {
      final response = await dio.get('/events/$eventId');
      if (response.statusCode == 200 || response.statusCode == 304) {
        return MyEventModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Error fetching event',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getEventById', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in getEventById', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> createEvent(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/events', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return data['id'] as String;
      }
      throw ServerException(
        message: 'Error creating event',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in createEvent', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in createEvent', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateEvent(String eventId, Map<String, dynamic> payload) async {
    try {
      final response = await dio.patch('/events/$eventId', data: payload);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Error updating event',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in updateEvent', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in updateEvent', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> submitEventForReview(String eventId) async {
    try {
      final response = await dio.patch('/events/$eventId/submit-review');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Error submitting for review',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in submitEventForReview', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in submitEventForReview', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unpublishEvent(String eventId) async {
    try {
      final response = await dio.patch('/events/$eventId/unpublish');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Error unpublishing event',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in unpublishEvent', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in unpublishEvent', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getUploadSignature({
    required String preset,
    String? eventId,
  }) async {
    try {
      final body = <String, dynamic>{
        'preset': preset,
        'uploadType': 'event',
        if (eventId != null) 'eventId': eventId,
      };
      final response = await dio.post('/uploads/signature', data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException(
        message: 'Error getting upload signature',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getUploadSignature', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in getUploadSignature', e, st);
      throw ServerException(message: e.toString());
    }
  }
}
