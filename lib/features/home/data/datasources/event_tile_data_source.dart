import 'package:dio/dio.dart';
import 'package:wap_app/features/home/data/models/tile_coords.dart';
import 'package:wap_app/features/home/data/models/tile_response.dart';
import 'package:wap_app/core/utils/app_logger.dart';

/// Servicio para obtener eventos usando el sistema de tiles
/// Consume el endpoint /events/tiles/:z/:x/:y del backend
class EventTileService {
  final Dio _dio;

  EventTileService(this._dio);

  /// Obtiene eventos de un tile específico
  Future<TileResponse> getTile({
    required int z,
    required int x,
    required int y,
    String? search,
    List<String>? categories,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMin,
    double? priceMax,
    String locale = 'es',
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories.join(',');
      }
      if (dateFrom != null) {
        queryParams['dateFrom'] = dateFrom.toIso8601String();
      }
      if (dateTo != null) {
        queryParams['dateTo'] = dateTo.toIso8601String();
      }
      if (priceMin != null) {
        queryParams['priceMin'] = priceMin;
      }
      if (priceMax != null) {
        queryParams['priceMax'] = priceMax;
      }

      AppLogger.info(
        '[EventTileService] Fetching tile $z/$x/$y with filters: $queryParams',
      );

      final response = await _dio.get(
        '/events/tiles/$z/$x/$y',
        queryParameters: queryParams,
        options: Options(
          headers: {'Accept-Language': locale, 'x-lang': locale},
        ),
      );

      final tileResponse = TileResponse.fromJson(response.data);

      AppLogger.info(
        '[EventTileService] Tile $z/$x/$y loaded: ${tileResponse.events.length} events, cached: ${tileResponse.metadata.cached}',
      );

      return tileResponse;
    } catch (e) {
      AppLogger.error('[EventTileService] Error fetching tile $z/$x/$y', e);
      rethrow;
    }
  }

  /// Obtiene múltiples tiles en paralelo
  Future<List<TileResponse>> getTiles({
    required List<TileCoords> tiles,
    String? search,
    List<String>? categories,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMin,
    double? priceMax,
    String locale = 'es',
  }) async {
    try {
      AppLogger.info(
        '[EventTileService] Fetching ${tiles.length} tiles in parallel',
      );

      final futures = tiles.map(
        (tile) => getTile(
          z: tile.z,
          x: tile.x,
          y: tile.y,
          search: search,
          categories: categories,
          dateFrom: dateFrom,
          dateTo: dateTo,
          priceMin: priceMin,
          priceMax: priceMax,
          locale: locale,
        ),
      );

      final responses = await Future.wait(futures);

      final totalEvents = responses.fold<int>(
        0,
        (sum, response) => sum + response.events.length,
      );

      AppLogger.info(
        '[EventTileService] Loaded ${tiles.length} tiles with $totalEvents total events',
      );

      return responses;
    } catch (e) {
      AppLogger.error('[EventTileService] Error fetching multiple tiles', e);
      rethrow;
    }
  }
}
