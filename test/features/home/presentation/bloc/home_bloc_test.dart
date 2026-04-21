// test/features/home/presentation/bloc/home_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';
import 'package:wap_app/features/home/domain/usecases/get_nearby_events.dart';
import 'package:wap_app/features/home/domain/usecases/get_events_for_map_bounds.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';

class MockEventRepository extends Mock implements EventRepository {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Event _makeEvent(
  String id, {
  double lat = 41.4,
  double lng = 2.1,
  double? distance,
  String? title,
  String? categorySlug,
  String? description,
  double? price,
  DateTime? startDate,
}) => Event(
  id: id,
  title: title ?? 'Event $id',
  startDate: startDate ?? DateTime(2026, 6, 1),
  latitude: lat,
  longitude: lng,
  distance: distance,
  categorySlug: categorySlug,
  description: description,
  price: price,
);

HomeBloc _makeBloc({EventRepository? repo}) {
  final r = repo ?? MockEventRepository();
  return HomeBloc(
    getNearbyEvents: GetNearbyEventsUseCase(r),
    getEventsForMapBounds: GetEventsForMapBoundsUseCase(r),
    tileProvider: null,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------
  test('initial state is HomeState() with defaults', () {
    final bloc = _makeBloc();
    expect(bloc.state.isLoading, isFalse);
    expect(bloc.state.events, isEmpty);
    expect(bloc.state.allEvents, isEmpty);
    expect(bloc.state.searchQuery, '');
    expect(bloc.state.hasLocationAccess, isTrue);
    bloc.close();
  });

  // ---------------------------------------------------------------------------
  // DeselectEvent
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'DeselectEvent clears selectedEvent and colocatedEvents',
    build: _makeBloc,
    seed: () => HomeState(
      selectedEvent: _makeEvent('e1'),
      colocatedEvents: [_makeEvent('e1'), _makeEvent('e2')],
      colocatedEventIndex: 1,
    ),
    act: (bloc) => bloc.add(const DeselectEvent()),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.selectedEvent, 'selectedEvent', isNull)
          .having((s) => s.colocatedEvents, 'colocatedEvents', isEmpty)
          .having((s) => s.colocatedEventIndex, 'colocatedEventIndex', 0),
    ],
  );

  // ---------------------------------------------------------------------------
  // UpdateVisibleEvents
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'UpdateVisibleEvents updates visibleEvents',
    build: _makeBloc,
    act: (bloc) =>
        bloc.add(UpdateVisibleEvents([_makeEvent('v1'), _makeEvent('v2')])),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.visibleEvents.map((e) => e.id).toList(),
        'ids',
        ['v1', 'v2'],
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // SelectEventMarker
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'SelectEventMarker selects a single event (no co-located)',
    build: _makeBloc,
    seed: () => HomeState(
      events: [_makeEvent('e1', lat: 41.4, lng: 2.1)],
      allEvents: [_makeEvent('e1', lat: 41.4, lng: 2.1)],
    ),
    act: (bloc) =>
        bloc.add(SelectEventMarker(_makeEvent('e1', lat: 41.4, lng: 2.1))),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.selectedEvent?.id, 'selectedEvent.id', 'e1')
          .having((s) => s.colocatedEventIndex, 'index', 0),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'SelectEventMarker finds co-located events nearby (< 20m)',
    build: _makeBloc,
    seed: () {
      final same = [
        _makeEvent('e1', lat: 41.4, lng: 2.1),
        _makeEvent('e2', lat: 41.40001, lng: 2.10001), // ~14m away
        _makeEvent('e3', lat: 42.0, lng: 3.0), // far away
      ];
      return HomeState(events: same, allEvents: same);
    },
    act: (bloc) =>
        bloc.add(SelectEventMarker(_makeEvent('e1', lat: 41.4, lng: 2.1))),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.colocatedEvents.length,
        'colocatedEvents.length',
        2, // e1 + e2
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // NextColocatedEvent / PreviousColocatedEvent
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'NextColocatedEvent advances index circularly',
    build: _makeBloc,
    seed: () => HomeState(
      selectedEvent: _makeEvent('e1'),
      colocatedEvents: [_makeEvent('e1'), _makeEvent('e2'), _makeEvent('e3')],
      colocatedEventIndex: 0,
    ),
    act: (bloc) => bloc.add(const NextColocatedEvent()),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.colocatedEventIndex, 'index', 1)
          .having((s) => s.selectedEvent?.id, 'selected', 'e2'),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'NextColocatedEvent wraps around from last to first',
    build: _makeBloc,
    seed: () => HomeState(
      selectedEvent: _makeEvent('e3'),
      colocatedEvents: [_makeEvent('e1'), _makeEvent('e2'), _makeEvent('e3')],
      colocatedEventIndex: 2,
    ),
    act: (bloc) => bloc.add(const NextColocatedEvent()),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.colocatedEventIndex, 'index', 0)
          .having((s) => s.selectedEvent?.id, 'selected', 'e1'),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'NextColocatedEvent does nothing when colocatedEvents is empty',
    build: _makeBloc,
    act: (bloc) => bloc.add(const NextColocatedEvent()),
    expect: () => [],
  );

  blocTest<HomeBloc, HomeState>(
    'PreviousColocatedEvent goes to previous index',
    build: _makeBloc,
    seed: () => HomeState(
      selectedEvent: _makeEvent('e2'),
      colocatedEvents: [_makeEvent('e1'), _makeEvent('e2'), _makeEvent('e3')],
      colocatedEventIndex: 1,
    ),
    act: (bloc) => bloc.add(const PreviousColocatedEvent()),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.colocatedEventIndex, 'index', 0)
          .having((s) => s.selectedEvent?.id, 'selected', 'e1'),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'PreviousColocatedEvent wraps from first to last',
    build: _makeBloc,
    seed: () => HomeState(
      selectedEvent: _makeEvent('e1'),
      colocatedEvents: [_makeEvent('e1'), _makeEvent('e2'), _makeEvent('e3')],
      colocatedEventIndex: 0,
    ),
    act: (bloc) => bloc.add(const PreviousColocatedEvent()),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.colocatedEventIndex, 'index', 2)
          .having((s) => s.selectedEvent?.id, 'selected', 'e3'),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'PreviousColocatedEvent does nothing when colocatedEvents is empty',
    build: _makeBloc,
    act: (bloc) => bloc.add(const PreviousColocatedEvent()),
    expect: () => [],
  );

  // ---------------------------------------------------------------------------
  // SearchEvents
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'SearchEvents filters by title',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [
        _makeEvent('e1', title: 'Flamenco Show'),
        _makeEvent('e2', title: 'Jazz Concert'),
        _makeEvent('e3', title: 'Flamenco Dance'),
      ],
    ),
    act: (bloc) => bloc.add(const SearchEvents('flamenco')),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.events.map((e) => e.id).toList(),
        'filtered ids',
        containsAll(['e1', 'e3']),
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'SearchEvents with empty query returns all events',
    build: _makeBloc,
    seed: () => HomeState(allEvents: [_makeEvent('e1'), _makeEvent('e2')]),
    act: (bloc) => bloc.add(const SearchEvents('')),
    expect: () => [
      isA<HomeState>().having((s) => s.events.length, 'length', 2),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'SearchEvents filters by description',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [
        _makeEvent('e1', description: 'Live jazz music in the park'),
        _makeEvent('e2', description: 'Flamenco dancing'),
      ],
    ),
    act: (bloc) => bloc.add(const SearchEvents('jazz')),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.events.map((e) => e.id).toList(),
        'ids',
        ['e1'],
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'SearchEvents stores searchQuery on state',
    build: _makeBloc,
    seed: () => HomeState(allEvents: [_makeEvent('e1', title: 'Jazz')]),
    act: (bloc) => bloc.add(const SearchEvents('jazz')),
    expect: () => [
      isA<HomeState>().having((s) => s.searchQuery, 'searchQuery', 'jazz'),
    ],
  );

  // ---------------------------------------------------------------------------
  // FilterEvents
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'FilterEvents by category slug',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [
        _makeEvent('e1', categorySlug: 'music'),
        _makeEvent('e2', categorySlug: 'sports'),
        _makeEvent('e3', categorySlug: 'music'),
      ],
    ),
    act: (bloc) => bloc.add(const FilterEvents(categories: ['music'])),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.events.map((e) => e.id).toList(),
        'ids',
        containsAll(['e1', 'e3']),
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'FilterEvents by onlyFree filters out paid events',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [
        _makeEvent('e1', price: 0.0),
        _makeEvent('e2', price: 20.0),
        _makeEvent('e3', price: null),
      ],
    ),
    act: (bloc) => bloc.add(const FilterEvents(onlyFree: true)),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.events.map((e) => e.id).toList(),
        'free ids',
        containsAll(['e1', 'e3']),
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'FilterEvents by minPrice and maxPrice',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [
        _makeEvent('e1', price: 5.0),
        _makeEvent('e2', price: 15.0),
        _makeEvent('e3', price: 30.0),
      ],
    ),
    act: (bloc) => bloc.add(const FilterEvents(minPrice: 10.0, maxPrice: 20.0)),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.events.map((e) => e.id).toList(),
        'ids in range',
        ['e2'],
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'FilterEvents by date range',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [
        _makeEvent('e1', startDate: DateTime(2026, 3, 1)),
        _makeEvent('e2', startDate: DateTime(2026, 6, 15)),
        _makeEvent('e3', startDate: DateTime(2026, 9, 1)),
      ],
    ),
    act: (bloc) => bloc.add(
      FilterEvents(
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 7, 31),
      ),
    ),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.events.map((e) => e.id).toList(),
        'ids in range',
        ['e2'],
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'FilterEvents stores filter params on state',
    build: _makeBloc,
    seed: () => HomeState(allEvents: []),
    act: (bloc) => bloc.add(
      FilterEvents(
        startDate: DateTime(2026, 1, 1),
        categories: ['music'],
        onlyFree: true,
        minPrice: 5.0,
        maxPrice: 50.0,
      ),
    ),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.filterCategories, 'categories', ['music'])
          .having((s) => s.filterOnlyFree, 'onlyFree', true)
          .having((s) => s.filterMinPrice, 'minPrice', 5.0)
          .having((s) => s.filterMaxPrice, 'maxPrice', 50.0),
    ],
  );

  // ---------------------------------------------------------------------------
  // ClearFilters
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'ClearFilters removes all filter state',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [_makeEvent('e1')],
      filterCategories: ['music'],
      filterOnlyFree: true,
      filterMinPrice: 5.0,
      filterMaxPrice: 50.0,
    ),
    act: (bloc) => bloc.add(const ClearFilters()),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.filterCategories, 'categories', isNull)
          .having((s) => s.filterOnlyFree, 'onlyFree', isNull)
          .having((s) => s.filterMinPrice, 'minPrice', isNull)
          .having((s) => s.filterMaxPrice, 'maxPrice', isNull),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'ClearFilters preserves searchQuery',
    build: _makeBloc,
    seed: () => HomeState(
      allEvents: [_makeEvent('e1', title: 'Jazz')],
      searchQuery: 'jazz',
      filterCategories: ['music'],
    ),
    act: (bloc) => bloc.add(const ClearFilters()),
    expect: () => [
      isA<HomeState>().having((s) => s.searchQuery, 'searchQuery', 'jazz'),
    ],
  );

  // ---------------------------------------------------------------------------
  // ZoomToCluster — co-located events
  // ---------------------------------------------------------------------------
  blocTest<HomeBloc, HomeState>(
    'ZoomToCluster with co-located events at low zoom emits zoomToPosition',
    build: _makeBloc,
    act: (bloc) => bloc.add(
      ZoomToCluster(
        center: const LatLng(41.4, 2.1),
        currentZoom: 12.0,
        clusterEvents: [
          _makeEvent('e1', lat: 41.4, lng: 2.1),
          _makeEvent('e2', lat: 41.40001, lng: 2.10001),
        ],
      ),
    ),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.zoomToPosition,
        'zoomToPosition',
        isNotNull,
      ),
      // Second emit clears the zoom target
      isA<HomeState>().having(
        (s) => s.zoomToPosition,
        'zoomToPosition cleared',
        isNull,
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'ZoomToCluster with co-located at max zoom selects events',
    build: _makeBloc,
    act: (bloc) => bloc.add(
      ZoomToCluster(
        center: const LatLng(41.4, 2.1),
        currentZoom: 16.0,
        clusterEvents: [
          _makeEvent('e1', lat: 41.4, lng: 2.1),
          _makeEvent('e2', lat: 41.40001, lng: 2.10001),
        ],
      ),
    ),
    expect: () => [
      isA<HomeState>().having((s) => s.selectedEvent, 'selected', isNotNull),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'ZoomToCluster with dispersed events emits then clears zoomToPosition',
    build: _makeBloc,
    act: (bloc) => bloc.add(
      ZoomToCluster(
        center: const LatLng(41.0, 2.0),
        currentZoom: 10.0,
        clusterEvents: [
          _makeEvent('e1', lat: 40.0, lng: 1.0),
          _makeEvent('e2', lat: 43.0, lng: 4.0),
        ],
      ),
    ),
    expect: () => [
      isA<HomeState>().having(
        (s) => s.zoomToPosition,
        'zoomToPosition set',
        isNotNull,
      ),
      isA<HomeState>().having(
        (s) => s.zoomToPosition,
        'zoomToPosition cleared',
        isNull,
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'ZoomToCluster does nothing when clusterEvents is empty',
    build: _makeBloc,
    act: (bloc) => bloc.add(
      const ZoomToCluster(
        center: LatLng(41.0, 2.0),
        currentZoom: 10.0,
        clusterEvents: [],
      ),
    ),
    expect: () => [],
  );
}
