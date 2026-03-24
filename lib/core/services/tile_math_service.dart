import 'dart:math';
import 'package:wap_app/features/home/data/models/tile_coords.dart';
import 'package:wap_app/features/home/data/models/tile_bounds.dart';

/// Servicio para cálculos matemáticos del sistema de tiles
/// Implementa el estándar Slippy Map Tiles (compatible con OSM, Google Maps, Mapbox)
class TileMathService {
  static const int minZoom =
      3; // Reducido de 6 a 3 para vistas regionales amplias
  static const int maxZoom = 11; // Máximo conservador
  static const int maxTiles = 50; // Límite estricto de tiles

  /// Convierte coordenadas Lat/Lng a coordenadas de Tile
  TileCoords latLngToTile(double lat, double lng, int zoom) {
    final n = pow(2, zoom);

    // Calcular X
    final x = ((lng + 180) / 360 * n).floor();

    // Calcular Y
    final latRad = lat * pi / 180;
    final y = ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * n).floor();

    return TileCoords(z: zoom, x: x, y: y);
  }

  /// Convierte coordenadas de Tile a Bounding Box
  TileBounds tileToBounds(int z, int x, int y) {
    final n = pow(2, z);

    final west = (x / n) * 360 - 180;
    final east = ((x + 1) / n) * 360 - 180;

    final north = _tile2lat(y, z);
    final south = _tile2lat(y + 1, z);

    return TileBounds(north: north, south: south, east: east, west: west);
  }

  /// Convierte coordenada Y del tile a latitud
  double _tile2lat(int y, int z) {
    final n = pow(2, z);
    // sinh(x) = (e^x - e^(-x)) / 2
    final value = pi * (1 - (2 * y) / n);
    final sinhValue = (exp(value) - exp(-value)) / 2;
    final latRad = atan(sinhValue);
    return latRad * 180 / pi;
  }

  /// Calcula todos los tiles necesarios para el viewport
  List<TileCoords> getTilesForViewport({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    required int zoom,
  }) {
    // Tiles de las esquinas
    final sw = latLngToTile(swLat, swLng, zoom);
    final ne = latLngToTile(neLat, neLng, zoom);

    final tiles = <TileCoords>[];

    // Generar todos los tiles en el rectángulo
    for (int x = sw.x; x <= ne.x; x++) {
      for (int y = ne.y; y <= sw.y; y++) {
        tiles.add(TileCoords(z: zoom, x: x, y: y));
      }
    }

    return tiles;
  }

  /// Calcula tiles expandiendo el viewport con un buffer
  /// Ajusta automáticamente el zoom si hay demasiados tiles
  List<TileCoords> getTilesForViewportWithBuffer({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    required int zoom,
    int bufferSize = 0,
  }) {
    int currentZoom = max(minZoom, min(maxZoom, zoom));
    List<TileCoords> tiles = [];

    // Calcular iterativamente el zoom correcto
    do {
      final sw = latLngToTile(swLat, swLng, currentZoom);
      final ne = latLngToTile(neLat, neLng, currentZoom);

      // Expandir con buffer
      final minX = max(0, sw.x - bufferSize);
      final maxX = min(pow(2, currentZoom).toInt() - 1, ne.x + bufferSize);
      final minY = max(0, ne.y - bufferSize);
      final maxY = min(pow(2, currentZoom).toInt() - 1, sw.y + bufferSize);

      final tilesX = maxX - minX + 1;
      final tilesY = maxY - minY + 1;
      final totalTiles = tilesX * tilesY;

      if (totalTiles > maxTiles && currentZoom > minZoom) {
        // Demasiados tiles, reducir zoom
        currentZoom--;
      } else {
        // Generar tiles
        tiles.clear();
        for (int x = minX; x <= maxX; x++) {
          for (int y = minY; y <= maxY; y++) {
            tiles.add(TileCoords(z: currentZoom, x: x, y: y));
          }
        }
        break;
      }
    } while (currentZoom >= minZoom);

    return tiles;
  }

  /// Determina el zoom óptimo según la distancia visible
  /// MUY CONSERVADOR para evitar cargar demasiados tiles
  int getOptimalZoom(double latitudeDelta) {
    // Vista MUNDIAL (> 100°) → Zoom muy bajo
    if (latitudeDelta > 100) return 3; // Mundo/multi-continente
    if (latitudeDelta > 50) return 4; // Continente
    if (latitudeDelta > 25) return 5; // Multi-país
    if (latitudeDelta > 12) return 6; // País grande
    if (latitudeDelta > 6) return 7; // País/región
    if (latitudeDelta > 3) return 8; // Región
    if (latitudeDelta > 1.5) return 9; // Ciudad grande
    if (latitudeDelta > 0.7) return 10; // Ciudad
    return 11; // Distrito/barrio
  }

  /// Calcula la distancia entre dos coordenadas en metros (Haversine)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // metros

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
