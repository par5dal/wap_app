// test/features/home/data/datasources/event_remote_data_source_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/features/home/data/datasources/event_remote_data_source.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

final tEventJson = {
  'id': 'evt-1',
  'title': 'Test Event',
  'start_datetime': '2026-06-01T20:00:00.000Z',
  'venue': {
    'id': 'v-1',
    'name': 'Test Venue',
    'address': '123 St',
    'location': {
      'type': 'Point',
      'coordinates': [2.0, 41.0],
    },
  },
};

void main() {
  late EventRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = EventRemoteDataSourceImpl(dio: mockDio);
  });

  // ---------------------------------------------------------------------------
  // getNearbyEvents
  // ---------------------------------------------------------------------------
  group('getNearbyEvents', () {
    test('returns list of EventModel on 200 with map format', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({
        'data': [tEventJson],
      });
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      expect(result, isA<List<EventModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'evt-1');
    });

    test('returns list of EventModel on 200 with list format', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn([tEventJson]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      expect(result.length, 1);
    });

    test('returns empty list on 304 with null data', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(304);
      when(() => mockResponse.data).thenReturn(null);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      expect(result, isEmpty);
    });

    test('throws ServerException on DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/events/search')),
      );

      expect(
        () => dataSource.getNearbyEvents(latitude: 41.0, longitude: 2.0),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException on non-200/304 status', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(() => mockResponse.data).thenReturn(null);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => dataSource.getNearbyEvents(latitude: 41.0, longitude: 2.0),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getEventById
  // ---------------------------------------------------------------------------
  group('getEventById', () {
    test('returns EventModel on 200 with nested data key', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({'data': tEventJson});
      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getEventById('evt-1');

      expect(result, isA<EventModel>());
      expect(result.id, 'evt-1');
    });

    test('returns EventModel on 200 with bare map format', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tEventJson);
      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getEventById('evt-1');

      expect(result.id, 'evt-1');
    });

    test('throws ServerException on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/events/eventos/x')),
      );

      expect(
        () => dataSource.getEventById('x'),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException on non-200/304 status', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(404);
      when(() => mockResponse.data).thenReturn(null);
      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      expect(
        () => dataSource.getEventById('x'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getEventsForMapBounds
  // ---------------------------------------------------------------------------
  group('getEventsForMapBounds', () {
    test('returns list of EventModel on 200', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({
        'data': [tEventJson],
      });
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getEventsForMapBounds(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      expect(result.length, 1);
      expect(result.first.id, 'evt-1');
    });

    test('returns empty list on null data', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(null);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getEventsForMapBounds(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      expect(result, isEmpty);
    });

    test('passes optional parameters in query', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({'data': []});
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      await dataSource.getEventsForMapBounds(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
        zoomLevel: '12',
        categoryId: 'cat-1',
        minPrice: 0,
        maxPrice: 50,
      );

      final captured = verify(
        () => mockDio.get(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      final params = captured.first as Map<String, dynamic>;
      expect(params['zoomLevel'], '12');
      expect(params['category_id'], 'cat-1');
    });

    test('throws ServerException on DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/events/clustering/map-points'),
        ),
      );

      expect(
        () => dataSource.getEventsForMapBounds(
          swLat: 40.0,
          swLng: 1.0,
          neLat: 42.0,
          neLng: 3.0,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getGridClusters
  // ---------------------------------------------------------------------------
  group('getGridClusters', () {
    test('returns list of maps on 200', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({
        'data': [
          {'lat': 41.0, 'lng': 2.0, 'count': 5},
        ],
      });
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getGridClusters(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      expect(result.length, 1);
      expect(result.first['count'], 5);
    });

    test('returns empty list on null data', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(null);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getGridClusters(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      expect(result, isEmpty);
    });

    test('throws ServerException on DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/events/clustering/grid'),
        ),
      );

      expect(
        () => dataSource.getGridClusters(
          swLat: 40.0,
          swLng: 1.0,
          neLat: 42.0,
          neLng: 3.0,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // recordView
  // ---------------------------------------------------------------------------
  group('recordView', () {
    test('completes without throwing on success', () async {
      when(
        () => mockDio.post(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 204),
      );

      await expectLater(dataSource.recordView('evt-1'), completes);
    });

    test('silences any exception (fire-and-forget)', () async {
      when(
        () => mockDio.post(any(), options: any(named: 'options')),
      ).thenThrow(Exception('network error'));

      // Should not throw
      await expectLater(dataSource.recordView('evt-1'), completes);
    });
  });
}
