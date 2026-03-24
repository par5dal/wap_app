// test/core/services/connectivity_service_test.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/services/connectivity_service.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityService service;

  setUp(() {
    mockConnectivity = MockConnectivity();
    service = ConnectivityService(connectivity: mockConnectivity);
  });

  group('isConnected stream', () {
    test('emits true when wifi is available', () async {
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      expect(service.isConnected, emits(true));
    });

    test('emits true when mobile data is available', () async {
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => Stream.value([ConnectivityResult.mobile]));

      expect(service.isConnected, emits(true));
    });

    test('emits true when ethernet is available', () async {
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => Stream.value([ConnectivityResult.ethernet]));

      expect(service.isConnected, emits(true));
    });

    test('emits false when no network is available', () async {
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => Stream.value([ConnectivityResult.none]));

      expect(service.isConnected, emits(false));
    });

    test('emits false for bluetooth-only (not internet)', () async {
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => Stream.value([ConnectivityResult.bluetooth]));

      expect(service.isConnected, emits(false));
    });

    test('emits multiple values as connectivity changes', () async {
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.fromIterable([
          [ConnectivityResult.wifi],
          [ConnectivityResult.none],
          [ConnectivityResult.mobile],
        ]),
      );

      expect(service.isConnected, emitsInOrder([true, false, true]));
    });

    test('emits true when one of multiple results is reachable', () async {
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.value([ConnectivityResult.none, ConnectivityResult.wifi]),
      );

      expect(service.isConnected, emits(true));
    });

    test('emits false when all results are none', () async {
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.value([ConnectivityResult.none, ConnectivityResult.none]),
      );

      expect(service.isConnected, emits(false));
    });
  });

  group('checkNow', () {
    test('returns true when wifi is available', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);

      expect(await service.checkNow(), isTrue);
    });

    test('returns true when mobile data is available', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.mobile]);

      expect(await service.checkNow(), isTrue);
    });

    test('returns true when ethernet is available', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.ethernet]);

      expect(await service.checkNow(), isTrue);
    });

    test('returns false when no network is available', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      expect(await service.checkNow(), isFalse);
    });

    test('returns false for empty results', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => []);

      expect(await service.checkNow(), isFalse);
    });

    test('returns true when at least one result is reachable', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.none, ConnectivityResult.mobile],
      );

      expect(await service.checkNow(), isTrue);
    });
  });
}
