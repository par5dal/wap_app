// lib/features/events/presentation/bloc/home_state.dart

part of 'home_bloc.dart';

/// Centinela para distinguir "no pasado" de "null explícito" en copyWith
const _omit = _Omit();

class _Omit {
  const _Omit();
}

class HomeState extends Equatable {
  final bool isLoading;
  final List<Event> allEvents; // Todos los eventos cargados originalmente
  final List<Event> events; // Eventos filtrados/buscados (los que se muestran)
  final List<Event>
  visibleEvents; // Eventos visibles en el viewport actual del mapa
  final Set<Marker> markers;
  final Event? selectedEvent;
  final List<Event>
  colocatedEvents; // Eventos en las mismas coordenadas que selectedEvent
  final int
  colocatedEventIndex; // Índice actual del evento seleccionado en colocatedEvents
  final LatLng? userLocation;
  final String? errorMessage;
  final String searchQuery;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final List<String>? filterCategories; // Cambiado a lista
  final bool? filterOnlyFree; // Nueva opción
  final double? filterMinPrice;
  final double? filterMaxPrice;
  final LatLng? lastLoadedPosition; // Última posición donde se cargaron eventos
  final double? lastZoomLevel; // Último nivel de zoom
  final LatLng? zoomToPosition; // Posición a la que hacer zoom (para clusters)
  final double? zoomToLevel; // Nivel de zoom target
  final bool hasLocationAccess; // Si se tiene acceso a la ubicación
  final String?
  locationErrorType; // Tipo de error de ubicación (disabled, denied, deniedForever)

  const HomeState({
    this.isLoading = false,
    this.allEvents = const [],
    this.events = const [],
    this.visibleEvents = const [],
    this.markers = const {},
    this.selectedEvent,
    this.colocatedEvents = const [],
    this.colocatedEventIndex = 0,
    this.userLocation,
    this.errorMessage,
    this.searchQuery = '',
    this.filterStartDate,
    this.filterEndDate,
    this.filterCategories,
    this.filterOnlyFree,
    this.filterMinPrice,
    this.filterMaxPrice,
    this.lastLoadedPosition,
    this.lastZoomLevel,
    this.zoomToPosition,
    this.zoomToLevel,
    this.hasLocationAccess = true,
    this.locationErrorType,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Event>? allEvents,
    List<Event>? events,
    List<Event>? visibleEvents,
    Set<Marker>? markers,
    Event? selectedEvent,
    List<Event>? colocatedEvents,
    int? colocatedEventIndex,
    LatLng? userLocation,
    String? errorMessage,
    String? searchQuery,
    Object? filterStartDate = _omit,
    Object? filterEndDate = _omit,
    Object? filterCategories = _omit,
    Object? filterOnlyFree = _omit,
    Object? filterMinPrice = _omit,
    Object? filterMaxPrice = _omit,
    LatLng? lastLoadedPosition,
    double? lastZoomLevel,
    LatLng? zoomToPosition,
    double? zoomToLevel,
    bool? hasLocationAccess,
    String? locationErrorType,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      allEvents: allEvents ?? this.allEvents,
      events: events ?? this.events,
      visibleEvents: visibleEvents ?? this.visibleEvents,
      markers: markers ?? this.markers,
      selectedEvent: selectedEvent,
      colocatedEvents: colocatedEvents ?? this.colocatedEvents,
      colocatedEventIndex: colocatedEventIndex ?? this.colocatedEventIndex,
      userLocation: userLocation ?? this.userLocation,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStartDate: filterStartDate == _omit
          ? this.filterStartDate
          : filterStartDate as DateTime?,
      filterEndDate: filterEndDate == _omit
          ? this.filterEndDate
          : filterEndDate as DateTime?,
      filterCategories: filterCategories == _omit
          ? this.filterCategories
          : filterCategories as List<String>?,
      filterOnlyFree: filterOnlyFree == _omit
          ? this.filterOnlyFree
          : filterOnlyFree as bool?,
      filterMinPrice: filterMinPrice == _omit
          ? this.filterMinPrice
          : filterMinPrice as double?,
      filterMaxPrice: filterMaxPrice == _omit
          ? this.filterMaxPrice
          : filterMaxPrice as double?,
      lastLoadedPosition: lastLoadedPosition ?? this.lastLoadedPosition,
      lastZoomLevel: lastZoomLevel ?? this.lastZoomLevel,
      zoomToPosition: zoomToPosition,
      zoomToLevel: zoomToLevel,
      hasLocationAccess: hasLocationAccess ?? this.hasLocationAccess,
      locationErrorType: locationErrorType,
    );
  }

  /// Verifica si hay algún filtro activo (excepto búsqueda)
  bool get hasActiveFilters {
    return filterStartDate != null ||
        filterEndDate != null ||
        (filterCategories != null && filterCategories!.isNotEmpty) ||
        filterOnlyFree == true ||
        (filterMinPrice != null && filterMinPrice! > 0) ||
        filterMaxPrice != null;
  }

  @override
  List<Object?> get props => [
    isLoading,
    allEvents,
    events,
    visibleEvents,
    markers,
    selectedEvent,
    colocatedEvents,
    colocatedEventIndex,
    userLocation,
    errorMessage,
    searchQuery,
    filterStartDate,
    filterEndDate,
    filterCategories,
    filterOnlyFree,
    filterMinPrice,
    filterMaxPrice,
    lastLoadedPosition,
    lastZoomLevel,
    zoomToPosition,
    zoomToLevel,
    hasLocationAccess,
    locationErrorType,
  ];
}
