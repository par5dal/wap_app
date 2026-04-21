// test/core/services/tile_math_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/core/services/tile_math_service.dart';
import 'package:wap_app/features/home/data/models/tile_coords.dart';

void main() {
  late TileMathService service;

  setUp(() {
    service = TileMathService();
  });

  // ---------------------------------------------------------------------------
  // latLngToTile
  // ---------------------------------------------------------------------------
  group('latLngToTile', () {
    test('converts known coords at zoom 10', () {
      // Barcelona: ~41.38°N, 2.17°E
      final tile = service.latLngToTile(41.38, 2.17, 10);
      expect(tile, isA<TileCoords>());
      expect(tile.z, 10);
      // At zoom 10: x should be ~523, y should be ~393
      expect(tile.x, greaterThan(500));
      expect(tile.y, greaterThan(350));
    });

    test('returns z matching requested zoom', () {
      final tile = service.latLngToTile(40.0, -3.0, 8);
      expect(tile.z, 8);
    });

    test('x increases as longitude increases', () {
      final west = service.latLngToTile(41.0, 0.0, 8);
      final east = service.latLngToTile(41.0, 10.0, 8);
      expect(east.x, greaterThan(west.x));
    });

    test('y increases as latitude decreases (tile Y is inverted)', () {
      final north = service.latLngToTile(50.0, 2.0, 8);
      final south = service.latLngToTile(30.0, 2.0, 8);
      expect(south.y, greaterThan(north.y));
    });
  });

  // ---------------------------------------------------------------------------
  // tileToBounds
  // ---------------------------------------------------------------------------
  group('tileToBounds', () {
    test('returns TileBounds with north > south', () {
      final bounds = service.tileToBounds(8, 130, 98);
      expect(bounds.north, greaterThan(bounds.south));
    });

    test('returns TileBounds with east > west', () {
      final bounds = service.tileToBounds(8, 130, 98);
      expect(bounds.east, greaterThan(bounds.west));
    });

    test(
      'round-trip: latLngToTile then tileToBounds contains original point',
      () {
        const lat = 41.38;
        const lng = 2.17;
        const zoom = 10;
        final tile = service.latLngToTile(lat, lng, zoom);
        final bounds = service.tileToBounds(zoom, tile.x, tile.y);

        expect(lat, greaterThanOrEqualTo(bounds.south));
        expect(lat, lessThanOrEqualTo(bounds.north));
        expect(lng, greaterThanOrEqualTo(bounds.west));
        expect(lng, lessThanOrEqualTo(bounds.east));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // getTilesForViewport
  // ---------------------------------------------------------------------------
  group('getTilesForViewport', () {
    test('returns at least one tile for a small area', () {
      final tiles = service.getTilesForViewport(
        swLat: 41.3,
        swLng: 2.1,
        neLat: 41.5,
        neLng: 2.3,
        zoom: 10,
      );
      expect(tiles, isNotEmpty);
    });

    test('all tiles have the requested zoom level', () {
      final tiles = service.getTilesForViewport(
        swLat: 41.0,
        swLng: 2.0,
        neLat: 42.0,
        neLng: 3.0,
        zoom: 9,
      );
      expect(tiles.every((t) => t.z == 9), isTrue);
    });

    test('returns more tiles for larger area', () {
      final small = service.getTilesForViewport(
        swLat: 41.3,
        swLng: 2.1,
        neLat: 41.4,
        neLng: 2.2,
        zoom: 10,
      );
      final large = service.getTilesForViewport(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 43.0,
        neLng: 4.0,
        zoom: 10,
      );
      expect(large.length, greaterThan(small.length));
    });
  });

  // ---------------------------------------------------------------------------
  // getTilesForViewportWithBuffer
  // ---------------------------------------------------------------------------
  group('getTilesForViewportWithBuffer', () {
    test('returns tiles with buffer=0', () {
      final tiles = service.getTilesForViewportWithBuffer(
        swLat: 41.3,
        swLng: 2.1,
        neLat: 41.5,
        neLng: 2.3,
        zoom: 10,
        bufferSize: 0,
      );
      expect(tiles, isNotEmpty);
    });

    test('returns at least as many tiles with buffer=1 vs buffer=0', () {
      final noBuffer = service.getTilesForViewportWithBuffer(
        swLat: 41.3,
        swLng: 2.1,
        neLat: 41.5,
        neLng: 2.3,
        zoom: 10,
        bufferSize: 0,
      );
      final withBuffer = service.getTilesForViewportWithBuffer(
        swLat: 41.3,
        swLng: 2.1,
        neLat: 41.5,
        neLng: 2.3,
        zoom: 10,
        bufferSize: 1,
      );
      expect(withBuffer.length, greaterThanOrEqualTo(noBuffer.length));
    });

    test('respects maxTiles limit by reducing zoom', () {
      // Very large area at high zoom could exceed maxTiles
      final tiles = service.getTilesForViewportWithBuffer(
        swLat: 30.0,
        swLng: -20.0,
        neLat: 55.0,
        neLng: 25.0,
        zoom: 11,
        bufferSize: 0,
      );
      expect(tiles.length, lessThanOrEqualTo(TileMathService.maxTiles));
    });

    test('clips zoom to minZoom..maxZoom range', () {
      final tilesHighZoom = service.getTilesForViewportWithBuffer(
        swLat: 41.3,
        swLng: 2.1,
        neLat: 41.5,
        neLng: 2.3,
        zoom: 999, // way above maxZoom
        bufferSize: 0,
      );
      expect(
        tilesHighZoom.every(
          (t) =>
              t.z >= TileMathService.minZoom && t.z <= TileMathService.maxZoom,
        ),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getOptimalZoom
  // ---------------------------------------------------------------------------
  group('getOptimalZoom', () {
    test('returns 3 for world view (>100°)', () {
      expect(service.getOptimalZoom(150), 3);
    });

    test('returns 4 for continent view (>50°)', () {
      expect(service.getOptimalZoom(60), 4);
    });

    test('returns 5 for multi-country (>25°)', () {
      expect(service.getOptimalZoom(30), 5);
    });

    test('returns 6 for country view (>12°)', () {
      expect(service.getOptimalZoom(15), 6);
    });

    test('returns 7 for region view (>6°)', () {
      expect(service.getOptimalZoom(8), 7);
    });

    test('returns 8 for sub-region (>3°)', () {
      expect(service.getOptimalZoom(4), 8);
    });

    test('returns 9 for large city (>1.5°)', () {
      expect(service.getOptimalZoom(2), 9);
    });

    test('returns 10 for city (>0.7°)', () {
      expect(service.getOptimalZoom(1.0), 10);
    });

    test('returns 11 for district/neighborhood', () {
      expect(service.getOptimalZoom(0.5), 11);
    });
  });

  // ---------------------------------------------------------------------------
  // calculateDistance (Haversine)
  // ---------------------------------------------------------------------------
  group('calculateDistance', () {
    test('returns 0 for same point', () {
      final d = service.calculateDistance(41.0, 2.0, 41.0, 2.0);
      expect(d, closeTo(0.0, 0.01));
    });

    test('known distance: Madrid to Barcelona ≈ 504 km', () {
      // Madrid: 40.4168°N, 3.7038°W
      // Barcelona: 41.3851°N, 2.1734°E
      final d = service.calculateDistance(40.4168, -3.7038, 41.3851, 2.1734);
      // In meters, should be roughly 504,000
      expect(d, closeTo(504000, 20000)); // ±20 km tolerance
    });

    test('is symmetric (A→B == B→A)', () {
      final d1 = service.calculateDistance(41.0, 2.0, 40.0, 3.0);
      final d2 = service.calculateDistance(40.0, 3.0, 41.0, 2.0);
      expect(d1, closeTo(d2, 0.1));
    });

    test('longer baseline has greater distance', () {
      final dShort = service.calculateDistance(41.0, 2.0, 41.1, 2.0);
      final dLong = service.calculateDistance(41.0, 2.0, 42.0, 2.0);
      expect(dLong, greaterThan(dShort));
    });
  });
}
