import 'package:flutter/foundation.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/features/home/data/datasources/event_tile_data_source.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';
import 'package:wap_app/features/home/data/models/tile_response.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/core/services/tile_math_service.dart';
import 'package:wap_app/core/utils/app_logger.dart';

/// Provider para gestionar tiles de eventos con sistema de caché acumulativo
class EventTileProvider extends ChangeNotifier {
  final EventTileService _service;
  final TileMathService _tileMath;

  // CACHÉ DE TILES (clave: "z/x/y", valor: TileResponse)
  final Map<String, TileResponse> _tileCache = {};

  // Configuración de caché
  static const Duration _cacheStaleTime = Duration(minutes: 10);
  static const Duration _cacheGcTime = Duration(minutes: 30);

  // Timestamps de tiles para expiración
  final Map<String, DateTime> _tileCacheTimes = {};

  // Metadata
  int _totalTiles = 0;
  int _loadedTiles = 0;
  int _cachedTiles = 0;
  bool _isLoading = false;
  int _currentZoom = 10;

  EventTileProvider(this._service, this._tileMath);

  // Getters
  bool get isLoading => _isLoading;
  int get totalTiles => _totalTiles;
  int get loadedTiles => _loadedTiles;
  int get cachedTiles => _cachedTiles;
  int get currentZoom => _currentZoom;
  double get cacheHitRate =>
      _totalTiles > 0 ? (_cachedTiles / _totalTiles) * 100 : 0;

  /// Obtiene todos los eventos únicos de todos los tiles cacheados
  /// FILTRADOS: Solo eventos que no han terminado aún
  List<Event> get allEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Deduplicar eventos por ID de todos los tiles
    final eventsMap = <String, Event>{};
    for (final tileResponse in _tileCache.values) {
      for (final eventModel in tileResponse.events) {
        final event = eventModel.toEntity();

        // FILTRO: Solo agregar eventos que NO han terminado
        // Comparar solo la fecha (sin hora) para que eventos de hoy se incluyan
        final eventEndDate = event.endDate ?? event.startDate;
        final eventEndDateOnly = DateTime(
          eventEndDate.year,
          eventEndDate.month,
          eventEndDate.day,
        );

        // El evento NO ha expirado si su fecha de fin es hoy o posterior
        final isNotExpired = !eventEndDateOnly.isBefore(today);

        // Filtrar eventos de promotores bloqueados
        final promoterId = event.promoterId;
        final isBlocked =
            promoterId != null &&
            sl<BlockedUsersService>().isBlocked(promoterId);

        if (isNotExpired && !isBlocked && !eventsMap.containsKey(event.id)) {
          eventsMap[event.id] = event;
        }
      }
    }
    return eventsMap.values.toList();
  }

  /// Obtiene tiles para el viewport actual
  Future<void> loadTilesForViewport({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    required double latitudeDelta,
    String? search,
    List<String>? categories,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMin,
    double? priceMax,
    String? locale,
    int bufferSize = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Calcular zoom óptimo
      final zoom = _tileMath.getOptimalZoom(latitudeDelta);
      _currentZoom = zoom;

      AppLogger.info(
        '[EventTileProvider] Loading tiles for viewport - latΔ: ${latitudeDelta.toStringAsFixed(2)}, zoom: $zoom',
      );

      // 2. Calcular tiles necesarios
      final tiles = _tileMath.getTilesForViewportWithBuffer(
        swLat: swLat,
        swLng: swLng,
        neLat: neLat,
        neLng: neLng,
        zoom: zoom,
        bufferSize: bufferSize,
      );

      _totalTiles = tiles.length;

      AppLogger.info(
        '[EventTileProvider] Calculated ${tiles.length} tiles needed for viewport',
      );

      // 3. Limpiar caché antiguo (GC)
      _cleanOldCache();

      // 3b. Limpiar tiles con eventos expirados
      _cleanTilesWithExpiredEvents();

      // 4. Filtrar tiles que NO están en caché o están stale
      final now = DateTime.now();
      final tilesToFetch = tiles.where((tile) {
        final key = tile.key;
        final cached = _tileCache.containsKey(key);

        if (!cached) return true;

        final cacheTime = _tileCacheTimes[key];
        if (cacheTime == null) return true;

        final isStale = now.difference(cacheTime) > _cacheStaleTime;
        return isStale;
      }).toList();

      _cachedTiles = _totalTiles - tilesToFetch.length;
      _loadedTiles = _cachedTiles;

      AppLogger.info(
        '[EventTileProvider] Cache hit: $_cachedTiles/$_totalTiles tiles (${cacheHitRate.toStringAsFixed(1)}%)',
      );

      if (tilesToFetch.isEmpty) {
        // Todos los tiles están en caché
        AppLogger.info('[EventTileProvider] All tiles from cache!');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 5. Cargar tiles nuevos/stale
      AppLogger.info(
        '[EventTileProvider] Fetching ${tilesToFetch.length} new/stale tiles',
      );

      final responses = await _service.getTiles(
        tiles: tilesToFetch,
        search: search,
        categories: categories,
        dateFrom: dateFrom,
        dateTo: dateTo,
        priceMin: priceMin,
        priceMax: priceMax,
        locale: locale ?? 'es',
      );

      // 6. Actualizar caché
      for (final response in responses) {
        final key = response.tile.key;
        _tileCache[key] = response;
        _tileCacheTimes[key] = now;
        _loadedTiles++;
      }

      AppLogger.info(
        '[EventTileProvider] Tiles loaded successfully: $_loadedTiles/$_totalTiles',
      );

      notifyListeners();
    } catch (e) {
      AppLogger.error('[EventTileProvider] Error loading tiles', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia tiles antiguos (Garbage Collection)
  void _cleanOldCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _tileCacheTimes.forEach((key, cacheTime) {
      if (now.difference(cacheTime) > _cacheGcTime) {
        keysToRemove.add(key);
      }
    });

    if (keysToRemove.isNotEmpty) {
      AppLogger.info(
        '[EventTileProvider] Garbage collecting ${keysToRemove.length} old tiles',
      );

      for (final key in keysToRemove) {
        _tileCache.remove(key);
        _tileCacheTimes.remove(key);
      }
    }
  }

  /// Limpia tiles que contienen eventos expirados
  /// Esto fuerza una recarga de tiles con eventos pasados
  void _cleanTilesWithExpiredEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final keysToRemove = <String>[];

    _tileCache.forEach((key, tileResponse) {
      // Verificar si este tile tiene algún evento expirado
      for (final eventModel in tileResponse.events) {
        final event = eventModel.toEntity();
        final eventEndDate = event.endDate ?? event.startDate;
        final eventEndDateOnly = DateTime(
          eventEndDate.year,
          eventEndDate.month,
          eventEndDate.day,
        );

        // Si encontramos un evento expirado, marcar este tile para eliminación
        if (eventEndDateOnly.isBefore(today)) {
          keysToRemove.add(key);
          break; // No necesitamos seguir revisando este tile
        }
      }
    });

    if (keysToRemove.isNotEmpty) {
      AppLogger.info(
        '[EventTileProvider] Removing ${keysToRemove.length} tiles with expired events',
      );

      for (final key in keysToRemove) {
        _tileCache.remove(key);
        _tileCacheTimes.remove(key);
      }

      notifyListeners();
    }
  }

  /// Limpia toda la caché (útil cuando cambian filtros)
  void clearCache() {
    AppLogger.info('[EventTileProvider] Clearing all cache');

    _tileCache.clear();
    _tileCacheTimes.clear();
    _totalTiles = 0;
    _loadedTiles = 0;
    _cachedTiles = 0;

    notifyListeners();
  }

  /// Obtiene estadísticas del caché
  Map<String, dynamic> getCacheStats() {
    return {
      'total_tiles': _totalTiles,
      'loaded_tiles': _loadedTiles,
      'cached_tiles': _cachedTiles,
      'cache_hit_rate': cacheHitRate,
      'total_events': allEvents.length,
      'current_zoom': _currentZoom,
      'is_loading': _isLoading,
    };
  }
}
