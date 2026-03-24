// lib/features/events/presentation/bloc/home_event.dart

part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyEvents extends HomeEvent {
  const LoadNearbyEvents();
}

class SelectEventMarker extends HomeEvent {
  final Event event;

  const SelectEventMarker(this.event);

  @override
  List<Object?> get props => [event];
}

class DeselectEvent extends HomeEvent {
  const DeselectEvent();
}

class RefreshEvents extends HomeEvent {
  const RefreshEvents();
}

class SearchEvents extends HomeEvent {
  final String query;

  const SearchEvents(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterEvents extends HomeEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final bool? onlyFree;
  final double? minPrice;
  final double? maxPrice;

  const FilterEvents({
    this.startDate,
    this.endDate,
    this.categories,
    this.onlyFree,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    categories,
    onlyFree,
    minPrice,
    maxPrice,
  ];
}

class ClearFilters extends HomeEvent {
  const ClearFilters();
}

/// Evento para cargar tiles del mapa usando el sistema de tiles
class LoadTilesForMapPosition extends HomeEvent {
  final double swLat;
  final double swLng;
  final double neLat;
  final double neLng;
  final double latitudeDelta;
  final int bufferSize;

  const LoadTilesForMapPosition({
    required this.swLat,
    required this.swLng,
    required this.neLat,
    required this.neLng,
    required this.latitudeDelta,
    this.bufferSize = 0,
  });

  @override
  List<Object?> get props => [
    swLat,
    swLng,
    neLat,
    neLng,
    latitudeDelta,
    bufferSize,
  ];
}

/// Evento para hacer zoom a un cluster con detección inteligente de co-ubicación
class ZoomToCluster extends HomeEvent {
  final LatLng center;
  final double currentZoom;
  final List<Event>
  clusterEvents; // Eventos del cluster para detectar co-ubicación

  const ZoomToCluster({
    required this.center,
    required this.currentZoom,
    required this.clusterEvents,
  });

  @override
  List<Object?> get props => [center, currentZoom, clusterEvents];
}

/// Evento para re-filtrar el mapa cuando cambia la lista de bloqueados
class HomeBlockedUsersChanged extends HomeEvent {
  const HomeBlockedUsersChanged();
}

/// Navegar al siguiente evento colocalizado
class NextColocatedEvent extends HomeEvent {
  const NextColocatedEvent();
}

/// Navegar al evento colocalizado anterior
class PreviousColocatedEvent extends HomeEvent {
  const PreviousColocatedEvent();
}

/// Actualizar los eventos visibles en el viewport del mapa
class UpdateVisibleEvents extends HomeEvent {
  final List<Event> visibleEvents;

  const UpdateVisibleEvents(this.visibleEvents);

  @override
  List<Object?> get props => [visibleEvents];
}
