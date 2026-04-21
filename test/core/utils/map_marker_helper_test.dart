// test/core/utils/map_marker_helper_test.dart
//
// NOTE: createClusterMarker, createColocatedMarker and createMarkerFromIcon use
// dart:ui Picture.toImage() which requires the GPU/Skia rendering backend.
// Those methods can only be tested via integration tests (flutter drive).

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/core/utils/map_marker_helper.dart';

void main() {
  group('MapMarkerHelper', () {
    // -- clearCache ------------------------------------------------------------
    group('clearCache()', () {
      test('completes without throwing', () {
        expect(() => MapMarkerHelper.clearCache(), returnsNormally);
      });

      test('can be called multiple times without error', () {
        MapMarkerHelper.clearCache();
        MapMarkerHelper.clearCache();
      });
    });
  });
}
