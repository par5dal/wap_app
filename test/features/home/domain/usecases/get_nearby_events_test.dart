// test/features/home/domain/usecases/get_nearby_events_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';
import 'package:wap_app/features/home/domain/usecases/get_nearby_events.dart';

class MockEventRepository extends Mock implements EventRepository {}

Event makeEvent(String id) => Event(
  id: id,
  title: 'Event $id',
  startDate: DateTime(2026, 6, 1),
  latitude: 40.4,
  longitude: -3.7,
);

void main() {
  late GetNearbyEventsUseCase useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetNearbyEventsUseCase(mockRepository);
  });

  const tLat = 40.416775;
  const tLng = -3.703790;
  const tRadius = 5000.0;

  test('should return list of events on success', () async {
    final tEvents = [makeEvent('1'), makeEvent('2')];

    when(
      () => mockRepository.getNearbyEvents(
        latitude: tLat,
        longitude: tLng,
        radius: tRadius,
      ),
    ).thenAnswer((_) async => Right(tEvents));

    final result = await useCase(
      latitude: tLat,
      longitude: tLng,
      radius: tRadius,
    );

    expect(result, Right(tEvents));
    verify(
      () => mockRepository.getNearbyEvents(
        latitude: tLat,
        longitude: tLng,
        radius: tRadius,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when no events nearby', () async {
    when(
      () => mockRepository.getNearbyEvents(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radius: any(named: 'radius'),
      ),
    ).thenAnswer((_) async => const Right([]));

    final result = await useCase(latitude: tLat, longitude: tLng);

    expect(result, const Right(<Event>[]));
  });

  test('should return ServerFailure on network error', () async {
    const tFailure = ServerFailure(message: 'No connection', statusCode: 503);

    when(
      () => mockRepository.getNearbyEvents(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radius: any(named: 'radius'),
      ),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(latitude: tLat, longitude: tLng);

    expect(result, const Left(tFailure));
  });

  test('should use default radius of 5000 when not provided', () async {
    when(
      () => mockRepository.getNearbyEvents(
        latitude: tLat,
        longitude: tLng,
        radius: 5000.0,
      ),
    ).thenAnswer((_) async => const Right([]));

    await useCase(latitude: tLat, longitude: tLng);

    verify(
      () => mockRepository.getNearbyEvents(
        latitude: tLat,
        longitude: tLng,
        radius: 5000.0,
      ),
    ).called(1);
  });
}
