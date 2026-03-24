// lib/features/home/data/datasources/public_events_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/home/data/models/category_model.dart';
import 'package:wap_app/features/home/data/models/map_point_model.dart';
import 'package:wap_app/features/home/data/models/paginated_events_response_model.dart';

abstract class PublicEventsRemoteDataSource {
  /// GET /events - Obtiene eventos p\u00fablicos con paginaci\u00f3n
  Future<PaginatedEventsResponseModel> getPublicEvents({
    required int page,
    required int limit,
    String? search,
    String? categories, // IDs separados por coma: "1,3,5"
    String? dateFrom, // ISO 8601
    String? dateTo,
    double? priceMin,
    double? priceMax,
    String? city,
    double? latitude,
    double? longitude,
    double? radius, // en km
  });

  /// GET /events/clustering/map-points - Obtiene puntos para el mapa
  Future<List<MapPointModel>> getMapPoints({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    required String zoomLevel, // 'country' | 'region' | 'city' | 'neighborhood'
    String? search,
    String? city,
    String? categories,
    String? dateFrom,
    String? dateTo,
    double? priceMin,
    double? priceMax,
  });

  /// GET /categories - Obtiene todas las categor\u00edas
  Future<List<CategoryModel>> getCategories();
}

class PublicEventsRemoteDataSourceImpl implements PublicEventsRemoteDataSource {
  final Dio dio;

  PublicEventsRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedEventsResponseModel> getPublicEvents({
    required int page,
    required int limit,
    String? search,
    String? categories,
    String? dateFrom,
    String? dateTo,
    double? priceMin,
    double? priceMax,
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (categories != null && categories.isNotEmpty) {
        queryParameters['categories'] = categories;
      }
      if (dateFrom != null) {
        queryParameters['dateFrom'] = dateFrom;
      }
      if (dateTo != null) {
        queryParameters['dateTo'] = dateTo;
      }
      if (priceMin != null && priceMin > 0) {
        queryParameters['priceMin'] = priceMin;
      }
      if (priceMax != null) {
        queryParameters['priceMax'] = priceMax;
      }
      if (city != null && city.isNotEmpty) {
        queryParameters['city'] = city;
      }
      if (latitude != null) {
        queryParameters['latitude'] = latitude;
      }
      if (longitude != null) {
        queryParameters['longitude'] = longitude;
      }
      if (radius != null) {
        queryParameters['radius'] = radius;
      }

      AppLogger.info('Fetching public events with params: $queryParameters');

      final response = await dio.get(
        '/events',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

        if (data == null) {
          return const PaginatedEventsResponseModel(
            events: [],
            total: 0,
            page: 1,
            limit: 10,
            totalPages: 0,
          );
        }

        return PaginatedEventsResponseModel.fromJson(
          data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: 'Failed to load public events',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getPublicEvents', e, e.stackTrace);

      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getPublicEvents', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MapPointModel>> getMapPoints({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    required String zoomLevel,
    String? search,
    String? city,
    String? categories,
    String? dateFrom,
    String? dateTo,
    double? priceMin,
    double? priceMax,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'swLat': swLat,
        'swLng': swLng,
        'neLat': neLat,
        'neLng': neLng,
        'zoomLevel': zoomLevel,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (city != null && city.isNotEmpty) {
        queryParameters['city'] = city;
      }
      if (categories != null && categories.isNotEmpty) {
        queryParameters['categories'] = categories;
      }
      if (dateFrom != null) {
        queryParameters['dateFrom'] = dateFrom;
      }
      if (dateTo != null) {
        queryParameters['dateTo'] = dateTo;
      }
      if (priceMin != null && priceMin > 0) {
        queryParameters['priceMin'] = priceMin;
      }
      if (priceMax != null) {
        queryParameters['priceMax'] = priceMax;
      }

      AppLogger.info('Fetching map points with params: $queryParameters');

      final response = await dio.get(
        '/events/clustering/map-points',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

        if (data == null || data is! List) {
          return [];
        }

        return (data).map((json) => MapPointModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to load map points',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getMapPoints', e, e.stackTrace);

      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getMapPoints', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      AppLogger.info('Fetching categories');

      final response = await dio.get('/categories');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

        if (data == null || data is! List) {
          return [];
        }

        return (data).map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to load categories',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getCategories', e, e.stackTrace);

      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getCategories', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }
}
