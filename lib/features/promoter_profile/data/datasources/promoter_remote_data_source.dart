// lib/features/promoter_profile/data/datasources/promoter_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';
import 'package:wap_app/features/promoter_profile/data/models/promoter_profile_model.dart';

abstract class PromoterRemoteDataSource {
  Future<PromoterProfileModel> getPromoterProfile(String promoterId);
  Future<List<EventModel>> getPromoterEvents({
    required String promoterId,
    int page = 1,
    int limit = 10,
  });
}

class PromoterRemoteDataSourceImpl implements PromoterRemoteDataSource {
  final Dio dio;

  PromoterRemoteDataSourceImpl({required this.dio});

  @override
  Future<PromoterProfileModel> getPromoterProfile(String promoterId) async {
    try {
      final response = await dio.get('/promoters/$promoterId');

      // 200 OK y 304 Not Modified son respuestas válidas
      if (response.statusCode == 200 || response.statusCode == 304) {
        return PromoterProfileModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Error getting promoter profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getPromoterProfile', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      } else {
        throw NetworkException(message: e.message ?? 'Network error');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in getPromoterProfile', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EventModel>> getPromoterEvents({
    required String promoterId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/events/promoter/$promoterId',
        queryParameters: {'page': page, 'limit': limit},
      );

      // 200 OK y 304 Not Modified son respuestas válidas
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
        final eventsJson = data['data'] as List;
        return eventsJson
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Error getting promoter events',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getPromoterEvents', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      } else {
        throw NetworkException(message: e.message ?? 'Network error');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in getPromoterEvents', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }
}
