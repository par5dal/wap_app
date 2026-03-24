// lib/features/home/presentation/providers/events_provider.dart

import 'package:flutter/material.dart';
import 'package:wap_app/features/home/domain/entities/event_filters.dart';

enum ViewMode { map, list }

/// Provider para manejar el estado compartido entre vista de mapa y lista
class EventsProvider extends ChangeNotifier {
  EventFilters _filters = const EventFilters();
  MapBounds? _mapBounds;
  ViewMode _viewMode = ViewMode.map;
  bool _isLoading = false;

  EventFilters get filters => _filters;
  MapBounds? get mapBounds => _mapBounds;
  ViewMode get viewMode => _viewMode;
  bool get isLoading => _isLoading;

  void updateFilters(EventFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void updateMapBounds(MapBounds bounds) {
    _mapBounds = bounds;
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearFilters() {
    _filters = _filters.clear();
    notifyListeners();
  }
}

/// Clase para representar los bounds del mapa
class MapBounds {
  final double swLat;
  final double swLng;
  final double neLat;
  final double neLng;
  final String zoomLevel;

  const MapBounds({
    required this.swLat,
    required this.swLng,
    required this.neLat,
    required this.neLng,
    required this.zoomLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'swLat': swLat,
      'swLng': swLng,
      'neLat': neLat,
      'neLng': neLng,
      'zoomLevel': zoomLevel,
    };
  }

  /// Calcula el zoom level basado en el delta de latitud
  static String calculateZoomLevel(double latitudeDelta) {
    if (latitudeDelta > 10) return 'country';
    if (latitudeDelta > 3) return 'region';
    if (latitudeDelta > 0.5) return 'city';
    return 'neighborhood';
  }
}
