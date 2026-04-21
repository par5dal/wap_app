// test/features/home/data/repositories/event_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/data/datasources/event_remote_data_source.dart';
import 'package:wap_app/features/home/data/datasources/location_data_source.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';
import 'package:wap_app/features/home/data/models/venue_model.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/data/repositories/event_repository_impl.dart';

class MockEventRemoteDataSource extends Mock implements EventRemoteDataSource {}

class MockLocationDataSource extends Mock implements LocationDataSource {}

final _tVenue = VenueModel(
  id: 'v-1',
  name: 'Test Venue',
  address: '123 St',
  location: const LocationModel(type: 'Point', coordinates: [2.0, 41.0]),
);

EventModel _makeModel(String id) => EventModel(
  id: id,
  title: 'Event $id',
  startDatetime: DateTime(2026, 6, 1, 20),
  venue: _tVenue,
);

void main() {
  late EventRepositoryImpl repository;
  late MockEventRemoteDataSource mockDataSource;
  late MockLocationDataSource mockLocationDataSource;

  setUp(() {
    mockDataSource = MockEventRemoteDataSource();
    mockLocationDataSource = MockLocationDataSource();
    repository = EventRepositoryImpl(
      remoteDataSource: mockDataSource,
      locationDataSource: mockLocationDataSource,
    );
  });

  // ---------------------------------------------------------------------------
  // getNearbyEvents
  // ---------------------------------------------------------------------------
  group('getNearbyEvents', () {
    test('returns Right(List<Event>) on success', () async {
      when(
        () => mockDataSource.getNearbyEvents(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radius: any(named: 'radius'),
        ),
      ).thenAnswer((_) async => [_makeModel('1'), _makeModel('2')]);

      final result = await repository.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (events) {
        expect(events.length, 2);
        expect(events.first, isA<Event>());
      });
    });

    test('returns Right(empty list) when datasource returns empty', () async {
      when(
        () => mockDataSource.getNearbyEvents(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radius: any(named: 'radius'),
        ),
      ).thenAnswer((_) async => []);

      final result = await repository.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      result.fold((_) => fail('should be right'), (events) {
        expect(events, isEmpty);
      });
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => mockDataSource.getNearbyEvents(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radius: any(named: 'radius'),
        ),
      ).thenThrow(ServerException(message: 'Server error', statusCode: 500));

      final result = await repository.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(
        () => mockDataSource.getNearbyEvents(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radius: any(named: 'radius'),
        ),
      ).thenThrow(NetworkException(message: 'No internet'));

      final result = await repository.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('returns Left(UnknownFailure) on unexpected exception', () async {
      when(
        () => mockDataSource.getNearbyEvents(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radius: any(named: 'radius'),
        ),
      ).thenThrow(Exception('Unexpected'));

      final result = await repository.getNearbyEvents(
        latitude: 41.0,
        longitude: 2.0,
      );

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getEventById
  // ---------------------------------------------------------------------------
  group('getEventById', () {
    test('returns Right(Event) on success', () async {
      when(
        () => mockDataSource.getEventById(any()),
      ).thenAnswer((_) async => _makeModel('evt-1'));

      final result = await repository.getEventById('evt-1');

      result.fold((_) => fail('should be right'), (event) {
        expect(event, isA<Event>());
        expect(event.id, 'evt-1');
      });
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => mockDataSource.getEventById(any()),
      ).thenThrow(ServerException(message: 'Not found', statusCode: 404));

      final result = await repository.getEventById('evt-1');

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(
        () => mockDataSource.getEventById(any()),
      ).thenThrow(NetworkException(message: 'No internet'));

      final result = await repository.getEventById('evt-1');

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('returns Left(UnknownFailure) on unexpected exception', () async {
      when(
        () => mockDataSource.getEventById(any()),
      ).thenThrow(Exception('fail'));

      final result = await repository.getEventById('evt-1');

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getEventsForMapBounds
  // ---------------------------------------------------------------------------
  group('getEventsForMapBounds', () {
    test('returns Right(List<Event>) on success', () async {
      when(
        () => mockDataSource.getEventsForMapBounds(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
          zoomLevel: any(named: 'zoomLevel'),
          categoryId: any(named: 'categoryId'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenAnswer((_) async => [_makeModel('1')]);

      final result = await repository.getEventsForMapBounds(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      result.fold((_) => fail('should be right'), (events) {
        expect(events.length, 1);
      });
    });

    test('calculates distance when userLatitude/Longitude provided', () async {
      when(
        () => mockDataSource.getEventsForMapBounds(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
          zoomLevel: any(named: 'zoomLevel'),
          categoryId: any(named: 'categoryId'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenAnswer((_) async => [_makeModel('1')]);

      final result = await repository.getEventsForMapBounds(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
        userLatitude: 41.0,
        userLongitude: 2.0,
      );

      result.fold((_) => fail('should be right'), (events) {
        expect(events.first.distance, isNotNull);
      });
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => mockDataSource.getEventsForMapBounds(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
          zoomLevel: any(named: 'zoomLevel'),
          categoryId: any(named: 'categoryId'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenThrow(ServerException(message: 'error', statusCode: 500));

      final result = await repository.getEventsForMapBounds(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(
        () => mockDataSource.getEventsForMapBounds(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
          zoomLevel: any(named: 'zoomLevel'),
          categoryId: any(named: 'categoryId'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenThrow(NetworkException(message: 'no internet'));

      final result = await repository.getEventsForMapBounds(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getGridClusters
  // ---------------------------------------------------------------------------
  group('getGridClusters', () {
    test('returns Right(list of maps) on success', () async {
      when(
        () => mockDataSource.getGridClusters(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
          gridSize: any(named: 'gridSize'),
          categoryId: any(named: 'categoryId'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenAnswer(
        (_) async => [
          {'lat': 41.0, 'lng': 2.0, 'count': 5},
        ],
      );

      final result = await repository.getGridClusters(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      result.fold((_) => fail('should be right'), (clusters) {
        expect(clusters.length, 1);
      });
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => mockDataSource.getGridClusters(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
          gridSize: any(named: 'gridSize'),
          categoryId: any(named: 'categoryId'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenThrow(ServerException(message: 'error', statusCode: 500));

      final result = await repository.getGridClusters(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(
        () => mockDataSource.getGridClusters(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
          gridSize: any(named: 'gridSize'),
          categoryId: any(named: 'categoryId'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenThrow(NetworkException(message: 'no internet'));

      final result = await repository.getGridClusters(
        swLat: 40.0,
        swLng: 1.0,
        neLat: 42.0,
        neLng: 3.0,
      );

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // recordView
  // ---------------------------------------------------------------------------
  group('recordView', () {
    test('delegates to datasource and completes', () async {
      when(() => mockDataSource.recordView(any())).thenAnswer((_) async {});

      await expectLater(repository.recordView('evt-1'), completes);

      verify(() => mockDataSource.recordView('evt-1')).called(1);
    });
  });
}
