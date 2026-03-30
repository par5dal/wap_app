// lib/features/events/data/datasources/event_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radius = 5000.0,
  });

  Future<EventModel> getEventById(String eventId);

  /// Obtiene eventos para clustering usando bounds del mapa
  Future<List<EventModel>> getEventsForMapBounds({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    String? zoomLevel,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  });

  /// Obtiene clusters agregados por el servidor (para zooms muy alejados)
  Future<List<Map<String, dynamic>>> getGridClusters({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    double gridSize = 0.5,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  });

  /// Registra una visita al evento (POST /events/:id/view → 204 No Content)
  Future<void> recordView(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EventModel>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radius = 5000.0,
  }) async {
    try {
      final response = await dio.get(
        '/events/search',
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'radius': radius.toString(),
        },
      );

      // 304 Not Modified significa que la caché es válida, usar los datos cacheados
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

        // Si es 304 y no hay datos (edge case), retornar lista vacía
        if (data == null) {
          return [];
        }

        // Manejar diferentes formatos de respuesta del backend
        List<dynamic> eventsList;
        if (data is Map<String, dynamic>) {
          eventsList = data['data'] as List<dynamic>? ?? [];
        } else if (data is List) {
          eventsList = data;
        } else {
          throw ServerException(
            message: 'Unexpected response format',
            statusCode: response.statusCode,
          );
        }

        // Convertir JSON a EventModel (sin calcular distancia aquí)
        final events = eventsList
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return events;
      } else {
        throw ServerException(
          message: 'Failed to load nearby events',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getNearbyEvents', e, e.stackTrace);

      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in getNearbyEvents', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    try {
      final response = await dio.get('/events/eventos/$eventId');

      // 304 Not Modified significa que la caché es válida
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

        Map<String, dynamic> eventData;
        if (data is Map<String, dynamic>) {
          eventData = data['data'] as Map<String, dynamic>? ?? data;
        } else {
          throw ServerException(
            message: 'Unexpected response format',
            statusCode: response.statusCode,
          );
        }

        return EventModel.fromJson(eventData);
      } else {
        throw ServerException(
          message: 'Failed to load event',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getEventById', e, e.stackTrace);

      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in getEventById', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EventModel>> getEventsForMapBounds({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    String? zoomLevel,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'swLat': swLat.toString(),
        'swLng': swLng.toString(),
        'neLat': neLat.toString(),
        'neLng': neLng.toString(),
      };

      if (zoomLevel != null) queryParams['zoomLevel'] = zoomLevel;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      final response = await dio.get(
        '/events/clustering/map-points',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

        if (data == null) return [];

        List<dynamic> eventsList;
        if (data is List) {
          eventsList = data;
        } else if (data is Map<String, dynamic>) {
          eventsList = data['data'] as List<dynamic>? ?? [];
        } else {
          throw ServerException(
            message: 'Unexpected response format',
            statusCode: response.statusCode,
          );
        }

        return eventsList
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to load events for map bounds',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getEventsForMapBounds', e, e.stackTrace);

      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in getEventsForMapBounds', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGridClusters({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    double gridSize = 0.5,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'swLat': swLat.toString(),
        'swLng': swLng.toString(),
        'neLat': neLat.toString(),
        'neLng': neLng.toString(),
        'gridSize': gridSize.toString(),
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      final response = await dio.get(
        '/events/clustering/grid',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

        if (data == null) return [];

        List<dynamic> clustersList;
        if (data is List) {
          clustersList = data;
        } else if (data is Map<String, dynamic>) {
          clustersList = data['data'] as List<dynamic>? ?? [];
        } else {
          throw ServerException(
            message: 'Unexpected response format',
            statusCode: response.statusCode,
          );
        }

        return clustersList
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to load grid clusters',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getGridClusters', e, e.stackTrace);

      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in getGridClusters', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> recordView(String eventId) async {
    try {
      await dio.post(
        '/events/$eventId/view',
        options: Options(
          validateStatus: (status) => status == 204 || status == 404,
        ),
      );
    } catch (_) {
      // Fire-and-forget: silenciar cualquier error de red o servidor
    }
  }
}
