// lib/features/promoter_dashboard/data/datasources/promoter_dashboard_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/promoter_dashboard/data/models/my_event_model.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_events_stats_entity.dart';

abstract class PromoterDashboardRemoteDataSource {
  Future<List<MyEventModel>> getMyEvents({
    int page = 1,
    int limit = 10,
    String? search,
  });

  Future<MyEventsStatsEntity> getMyEventsStats();

  Future<void> deleteEvent(String eventId);

  Future<void> submitEventForReview(String eventId);

  Future<void> unpublishEvent(String eventId);
}

class PromoterDashboardRemoteDataSourceImpl
    implements PromoterDashboardRemoteDataSource {
  final Dio dio;

  PromoterDashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MyEventModel>> getMyEvents({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Fetch events list and per-event stats in parallel
      final results = await Future.wait([
        dio.get('/events/my-events', queryParameters: queryParams),
        dio.get('/events/my-events/stats'),
      ]);

      final eventsResponse = results[0];
      final statsResponse = results[1];

      if (eventsResponse.statusCode != 200 &&
          eventsResponse.statusCode != 304) {
        throw ServerException(
          message: 'Error fetching events',
          statusCode: eventsResponse.statusCode,
        );
      }

      // Build a map of event_id → favorites_count from the stats endpoint
      final Map<String, int> favoritesMap = {};
      if (statsResponse.data is List) {
        for (final item in statsResponse.data as List) {
          final s = item as Map<String, dynamic>;
          final id = s['event_id']?.toString();
          if (id != null) {
            favoritesMap[id] = (s['favorites_count'] as num?)?.toInt() ?? 0;
          }
        }
      }

      final List<dynamic> items = (eventsResponse.data['data'] as List?) ?? [];
      return items.map((e) {
        final json = Map<String, dynamic>.from(e as Map<String, dynamic>);
        // Inject favorites_count from the stats endpoint
        json['favorites_count'] = favoritesMap[json['id']?.toString()];
        return MyEventModel.fromJson(json);
      }).toList();
    } on DioException catch (e) {
      AppLogger.error('DioException in getMyEvents', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in getMyEvents', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MyEventsStatsEntity> getMyEventsStats() async {
    try {
      // Fetch stats with independent error handling
      // so one failure doesn't block the other
      Response? eventsResponse;
      Response? followersResponse;

      try {
        eventsResponse = await dio.get('/events/my-events/stats');
      } catch (e) {
        AppLogger.warning('Failed to fetch /events/my-events/stats', e, null);
      }

      try {
        followersResponse = await dio.get(
          '/promoters/me/follower-stats',
          options: Options(
            extra: CacheOptions(
              store: MemCacheStore(),
              policy: CachePolicy.noCache,
            ).toExtra(),
          ),
        );
      } catch (e) {
        AppLogger.warning(
          'Failed to fetch /promoters/me/follower-stats',
          e,
          null,
        );
      }

      // Aggregate per-event stats (backend returns a list)
      int totalEvents = 0;
      int activeEvents = 0;
      int totalViews = 0;
      int totalFavorites = 0;
      if (eventsResponse != null && eventsResponse.data is List) {
        final list = eventsResponse.data as List;
        totalEvents = list.length;
        for (final item in list) {
          final s = item as Map<String, dynamic>;
          totalViews += (s['views_count'] as num?)?.toInt() ?? 0;
          totalFavorites += (s['favorites_count'] as num?)?.toInt() ?? 0;
          final status = (s['status'] as String?) ?? '';
          if (status == 'PUBLISHED') activeEvents++;
        }
      }

      // Follower count
      // Note: we intentionally skip the statusCode check here because
      // DioCacheInterceptor may return status 304 (or a cached 200) depending
      // on interceptor order. As long as we have a Map with 'total_followers'
      // we can safely parse it.
      int totalFollowers = 0;
      if (followersResponse != null &&
          followersResponse.data is Map<String, dynamic>) {
        totalFollowers =
            (followersResponse.data['total_followers'] as num?)?.toInt() ?? 0;
        AppLogger.debug(
          'follower-stats → status=${followersResponse.statusCode} total_followers=$totalFollowers',
        );
      } else {
        AppLogger.warning(
          'follower-stats → unexpected response: status=${followersResponse?.statusCode} dataType=${followersResponse?.data.runtimeType}',
          null,
          null,
        );
      }

      return MyEventsStatsEntity(
        totalEvents: totalEvents,
        activeEvents: activeEvents,
        totalViews: totalViews,
        totalFavorites: totalFavorites,
        totalFollowers: totalFollowers,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getMyEventsStats', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in getMyEventsStats', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await dio.delete('/events/$eventId');
      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 202) {
        throw ServerException(
          message: 'Error deleting event',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in deleteEvent', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    } catch (e, st) {
      AppLogger.error('Error in deleteEvent', e, st);
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
}
