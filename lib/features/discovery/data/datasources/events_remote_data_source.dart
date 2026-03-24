import 'package:dio/dio.dart';
import 'package:wap_app/core/network/paginated_response.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';

abstract class EventsRemoteDataSource {
  Future<PaginatedResponse<Event>> getEventsByCategory(
    String categorySlug, {
    int page = 1,
    int limit = 20,
  });
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final Dio dio;

  EventsRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedResponse<Event>> getEventsByCategory(
    String categorySlug, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/events/eventos/categoria/$categorySlug',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Si la respuesta tiene formato con meta (paginación)
      if (response.data['meta'] != null) {
        final eventModels = (response.data['data'] as List)
            .map((e) => EventModel.fromJson(e))
            .toList();

        return PaginatedResponse<Event>(
          data: eventModels.map((model) => model.toEntity()).toList(),
          meta: PaginationMeta.fromJson(response.data['meta']),
        );
      } else {
        // Si la respuesta es directa sin meta
        final events = response.data is List
            ? response.data as List
            : response.data['data'] as List? ?? [];

        final eventModels = events.map((e) => EventModel.fromJson(e)).toList();

        return PaginatedResponse<Event>(
          data: eventModels.map((model) => model.toEntity()).toList(),
          meta: PaginationMeta(
            page: page,
            limit: limit,
            total: events.length,
            totalPages: 1,
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
