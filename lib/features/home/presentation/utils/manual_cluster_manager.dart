// lib/features/home/presentation/utils/manual_cluster_manager.dart

import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/core/utils/map_marker_helper.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';

/// Cluster manual de eventos con control de distancia real en kilómetros
class EventCluster {
  final LatLng location;
  final List<Event> events;
  final String id;

  EventCluster({
    required this.location,
    required this.events,
    required this.id,
  });

  bool get isSingle => events.length == 1;
  int get count => events.length;
}

/// Manager de clustering manual con control de distancia real usando Haversine
class ManualClusterManager {
  final Function(Set<Marker>) onMarkersChanged;
  final Function(Event) onMarkerTap;
  final Function(EventCluster) onClusterTap;

  List<Event> _events = [];
  double _currentZoom = 14.0;
  Set<Marker> _markers = {};

  /// Pixel ratio del dispositivo — configurar desde el widget con MediaQuery
  double pixelRatio = 1.0;

  ManualClusterManager({
    required this.onMarkersChanged,
    required this.onMarkerTap,
    required this.onClusterTap,
  });

  /// Actualiza los eventos y recalcula clusters
  Future<void> setEvents(List<Event> events, double zoom) async {
    _events = events;
    _currentZoom = zoom;
    await _updateClusters();
  }

  /// Calcula la distancia máxima de agrupación según el nivel de zoom
  double _getClusteringDistanceKm(double zoom) {
    if (zoom < 4) return 500.0; // Vista continental
    if (zoom < 5) return 150.0; // Comunidad autónoma
    if (zoom < 8) return 50.0; // Provincia (~50km)
    if (zoom < 12) return 10.0; // Ciudad (~10km)
    if (zoom < 14) return 2.0; // Barrio (~2km)
    return 0.0; // Individual (zoom 14+)
  }

  /// Calcula la distancia entre dos coordenadas usando la fórmula de Haversine (en km)
  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Clustering grid-based O(n):
  /// Divide el espacio en celdas del tamaño del radio y solo comprueba
  /// las 9 celdas propias + adyacentes, evitando el doble bucle O(n²).
  Future<void> _updateClusters() async {
    if (_events.isEmpty) {
      _markers = {};
      onMarkersChanged(_markers);
      return;
    }

    final maxDistanceKm = _getClusteringDistanceKm(_currentZoom);

    AppLogger.info(
      '[ManualCluster] Clustering ${_events.length} events at zoom '
      '$_currentZoom (radius: ${maxDistanceKm}km)',
    );

    // Zoom 14+: markers individuales, EXCEPTO eventos co-localizados
    // (misma posición o a menos de ~10 metros, 0.0001°)
    if (maxDistanceKm == 0.0) {
      const colocatedThresholdDeg = 0.0001; // ~10 metros
      final Map<String, List<Event>> byPosition = {};
      for (final event in _events) {
        final col = (event.longitude / colocatedThresholdDeg).floor();
        final row = (event.latitude / colocatedThresholdDeg).floor();
        final key = '${col}_$row';
        byPosition.putIfAbsent(key, () => []).add(event);
      }

      final markers = <Marker>{};
      for (final group in byPosition.values) {
        if (group.length == 1) {
          markers.add(await _createMarkerForEvent(group.first));
        } else {
          // Varios eventos en la misma posición → cluster fijo
          final centerLat =
              group.map((e) => e.latitude).reduce((a, b) => a + b) /
              group.length;
          final centerLng =
              group.map((e) => e.longitude).reduce((a, b) => a + b) /
              group.length;
          markers.add(
            await _createMarkerForCluster(
              EventCluster(
                location: LatLng(centerLat, centerLng),
                events: group,
                id: group.map((e) => e.id).join('_'),
              ),
            ),
          );
        }
      }
      _markers = markers;
      onMarkersChanged(_markers);
      return;
    }

    // 1. Construir grid espacial
    //    1 grado de latitud ≈ 111 km  →  cellSizeDeg = radio / 111
    final double cellSizeDeg = maxDistanceKm / 111.0;
    final Map<String, List<Event>> grid = {};
    for (final event in _events) {
      final key = _cellKey(event.latitude, event.longitude, cellSizeDeg);
      grid.putIfAbsent(key, () => []).add(event);
    }

    // 2. Recorrer eventos y agrupar con sus vecinos de celda
    final clusters = <EventCluster>[];
    final processed = <String>{};

    for (final event in _events) {
      if (processed.contains(event.id)) continue;

      processed.add(event.id);
      final nearbyEvents = <Event>[event];

      final col = (event.longitude / cellSizeDeg).floor();
      final row = (event.latitude / cellSizeDeg).floor();

      // Revisar las 9 celdas (propia + 8 vecinas)
      for (int dc = -1; dc <= 1; dc++) {
        for (int dr = -1; dr <= 1; dr++) {
          final neighborKey = '${col + dc}_${row + dr}';
          for (final other in grid[neighborKey] ?? []) {
            if (processed.contains(other.id)) continue;
            if (_calculateDistanceKm(
                  event.latitude,
                  event.longitude,
                  other.latitude,
                  other.longitude,
                ) <=
                maxDistanceKm) {
              nearbyEvents.add(other);
              processed.add(other.id);
            }
          }
        }
      }

      // Centro del cluster = promedio de coordenadas
      final centerLat =
          nearbyEvents.map((e) => e.latitude).reduce((a, b) => a + b) /
          nearbyEvents.length;
      final centerLng =
          nearbyEvents.map((e) => e.longitude).reduce((a, b) => a + b) /
          nearbyEvents.length;

      clusters.add(
        EventCluster(
          location: LatLng(centerLat, centerLng),
          events: nearbyEvents,
          id: nearbyEvents.map((e) => e.id).join('_'),
        ),
      );
    }

    AppLogger.info(
      '[ManualCluster] ${clusters.length} clusters from ${_events.length} events',
    );

    // 3. Crear markers
    final markers = <Marker>{};
    for (final cluster in clusters) {
      markers.add(await _createMarkerForCluster(cluster));
    }
    _markers = markers;
    onMarkersChanged(_markers);
  }

  /// Genera la clave de celda del grid para unas coordenadas dadas
  String _cellKey(double lat, double lng, double cellSizeDeg) {
    final col = (lng / cellSizeDeg).floor();
    final row = (lat / cellSizeDeg).floor();
    return '${col}_$row';
  }

  /// Crea un marker para un evento individual
  Future<Marker> _createMarkerForEvent(Event event) async {
    final categoryColor = MapMarkerHelper.getCategoryColor(event.categorySlug);

    final BitmapDescriptor markerIcon;
    if (event.categorySvg != null && event.categorySvg!.isNotEmpty) {
      markerIcon = await MapMarkerHelper.createMarkerFromSvg(
        svgString: event.categorySvg!,
        color: categoryColor,
        size: 40.0 * pixelRatio,
        pixelRatio: pixelRatio,
      );
    } else {
      final icon = MapMarkerHelper.getCategoryIcon(event.categorySlug);
      markerIcon = await MapMarkerHelper.createMarkerFromIcon(
        icon: icon,
        color: categoryColor,
        size: 40.0 * pixelRatio,
        pixelRatio: pixelRatio,
      );
    }

    return Marker(
      markerId: MarkerId(event.id),
      position: LatLng(event.latitude, event.longitude),
      icon: markerIcon,
      onTap: () => onMarkerTap(event),
    );
  }

  /// Crea un marker para un cluster de eventos
  Future<Marker> _createMarkerForCluster(EventCluster cluster) async {
    if (cluster.isSingle) {
      return _createMarkerForEvent(cluster.events.first);
    }

    final icon = await MapMarkerHelper.createClusterMarker(
      count: cluster.count,
      size: 45.0 * pixelRatio,
      pixelRatio: pixelRatio,
    );

    return Marker(
      markerId: MarkerId(cluster.id),
      position: cluster.location,
      icon: icon,
      onTap: () => onClusterTap(cluster),
    );
  }

  /// Actualiza el zoom y recalcula clusters si es necesario
  Future<void> updateZoom(double newZoom) async {
    final oldRange = _getZoomRange(_currentZoom);
    final newRange = _getZoomRange(newZoom);

    // Recalcular si cambió el rango de clustering
    if (oldRange != newRange) {
      AppLogger.info(
        '[ManualCluster] Zoom range changed: $oldRange -> $newRange (${_currentZoom.toStringAsFixed(1)} -> ${newZoom.toStringAsFixed(1)})',
      );
      _currentZoom = newZoom;
      await _updateClusters();
    } else {
      _currentZoom = newZoom;
    }
  }

  String _getZoomRange(double zoom) {
    if (zoom < 4) return 'country';
    if (zoom < 5) return 'region';
    if (zoom < 8) return 'province';
    if (zoom < 12) return 'city';
    if (zoom < 14) return 'neighborhood';
    return 'individual';
  }
}
