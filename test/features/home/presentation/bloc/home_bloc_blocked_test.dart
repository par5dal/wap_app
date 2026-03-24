// test/features/home/presentation/bloc/home_bloc_blocked_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';
import 'package:wap_app/features/home/domain/usecases/get_nearby_events.dart';
import 'package:wap_app/features/home/domain/usecases/get_events_for_map_bounds.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/home/presentation/providers/event_tile_provider.dart';
import 'package:wap_app/features/home/data/datasources/event_tile_data_source.dart';
import 'package:wap_app/core/services/tile_math_service.dart';

class MockEventRepository extends Mock implements EventRepository {}

class MockEventTileService extends Mock implements EventTileService {}

class MockTileMathService extends Mock implements TileMathService {}

/// Fake EventTileProvider que expone una lista configurable desde allEvents.
class FakeEventTileProvider extends EventTileProvider {
  final List<Event> _events;

  FakeEventTileProvider(this._events)
    : super(MockEventTileService(), MockTileMathService());

  @override
  List<Event> get allEvents => _events;
}

Event makeEvent(String id) => Event(
  id: id,
  title: 'Event $id',
  startDate: DateTime(2099, 1, 1), // Far future so it's not expired
  latitude: 40.4,
  longitude: -3.7,
);

void main() {
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
  });

  group('HomeBlockedUsersChanged', () {
    test('does nothing when tileProvider is null', () async {
      final bloc = HomeBloc(
        getNearbyEvents: GetNearbyEventsUseCase(mockRepository),
        getEventsForMapBounds: GetEventsForMapBoundsUseCase(mockRepository),
        tileProvider: null,
      );

      final initialState = bloc.state;
      bloc.add(const HomeBlockedUsersChanged());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, initialState);
      await bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      're-filters allEvents from tileProvider and updates state',
      build: () {
        final events = [makeEvent('1'), makeEvent('2'), makeEvent('3')];
        final fakeProvider = FakeEventTileProvider(events);
        return HomeBloc(
          getNearbyEvents: GetNearbyEventsUseCase(mockRepository),
          getEventsForMapBounds: GetEventsForMapBoundsUseCase(mockRepository),
          tileProvider: fakeProvider,
        );
      },
      act: (bloc) => bloc.add(const HomeBlockedUsersChanged()),
      verify: (bloc) {
        // After the event, allEvents/events/visibleEvents should contain
        // whatever tileProvider.allEvents returns (3 events here).
        expect(bloc.state.allEvents.length, 3);
        expect(bloc.state.events.length, 3);
        expect(bloc.state.visibleEvents.length, 3);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'keeps current search query filter applied after blocked users change',
      build: () {
        // Two events, one matching 'specific' in title
        final events = [
          Event(
            id: '1',
            title: 'Specific Event',
            startDate: DateTime(2099, 1, 1),
            latitude: 40.4,
            longitude: -3.7,
          ),
          Event(
            id: '2',
            title: 'Other Event',
            startDate: DateTime(2099, 1, 1),
            latitude: 40.4,
            longitude: -3.7,
          ),
        ];
        final fakeProvider = FakeEventTileProvider(events);
        return HomeBloc(
          getNearbyEvents: GetNearbyEventsUseCase(mockRepository),
          getEventsForMapBounds: GetEventsForMapBoundsUseCase(mockRepository),
          tileProvider: fakeProvider,
        );
      },
      seed: () => const HomeState(searchQuery: 'specific'),
      act: (bloc) => bloc.add(const HomeBlockedUsersChanged()),
      verify: (bloc) {
        // Only the matching event should appear in events/visibleEvents
        expect(bloc.state.events.length, 1);
        expect(bloc.state.events.first.id, '1');
        // allEvents should still have both (unfiltered cache)
        expect(bloc.state.allEvents.length, 2);
      },
    );
  });
}
