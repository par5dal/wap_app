// lib/features/events/presentation/bloc/home_bloc.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/usecases/get_nearby_events.dart';
import 'package:wap_app/features/home/domain/usecases/get_events_for_map_bounds.dart';
import 'package:wap_app/features/home/presentation/providers/event_tile_provider.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetNearbyEventsUseCase getNearbyEvents;
  final GetEventsForMapBoundsUseCase getEventsForMapBounds;
  final EventTileProvider? tileProvider;

  // Guard against concurrent Geolocator.requestPermission() calls (iOS throws
  // PermissionRequestInProgressException if two requests overlap).
  Future<LocationPermission>? _permissionRequest;

  // Guard against concurrent LoadNearbyEvents executions. If a load is already
  // in progress, additional events are dropped until it completes.
  bool _loadNearbyEventsInProgress = false;

  HomeBloc({
    required this.getNearbyEvents,
    required this.getEventsForMapBounds,
    this.tileProvider,
  }) : super(const HomeState()) {
    on<LoadNearbyEvents>(_onLoadNearbyEvents);
    on<SelectEventMarker>(_onSelectEventMarker);
    on<DeselectEvent>(_onDeselectEvent);
    on<RefreshEvents>(_onRefreshEvents);
    on<SearchEvents>(_onSearchEvents);
    on<FilterEvents>(_onFilterEvents);
    on<ClearFilters>(_onClearFilters);
    on<LoadTilesForMapPosition>(_onLoadTilesForMapPosition);
    on<ZoomToCluster>(_onZoomToCluster);
    on<NextColocatedEvent>(_onNextColocatedEvent);
    on<PreviousColocatedEvent>(_onPreviousColocatedEvent);
    on<UpdateVisibleEvents>(_onUpdateVisibleEvents);
    on<HomeBlockedUsersChanged>(_onBlockedUsersChanged);
  }

  Future<void> _onLoadNearbyEvents(
    LoadNearbyEvents event,
    Emitter<HomeState> emit,
  ) async {
    // Drop duplicate concurrent loads — iOS Geolocator throws
    // PermissionRequestInProgressException if two calls overlap.
    if (_loadNearbyEventsInProgress) {
      AppLogger.info(
        '[HomeBloc] LoadNearbyEvents already in progress, skipping.',
      );
      return;
    }
    _loadNearbyEventsInProgress = true;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Obtener ubicación del usuario
      AppLogger.info('[HomeBloc] Getting user location...');
      final position = await _determinePosition();
      final userLocation = LatLng(position.latitude, position.longitude);

      AppLogger.info(
        '[HomeBloc] User location: ${position.latitude}, ${position.longitude}',
      );

      // USAR SISTEMA DE TILES desde el inicio (más confiable que getNearbyEvents)
      if (tileProvider != null) {
        AppLogger.info('[HomeBloc] Loading tiles for initial viewport...');

        // Calcular bounds para un área visible en zoom 14
        // En zoom 14, cada grado de latitud ≈ 0.02° (aproximadamente 2.2 km)
        const double delta = 0.02; // Área pequeña alrededor del usuario
        final swLat = position.latitude - delta;
        final swLng = position.longitude - delta;
        final neLat = position.latitude + delta;
        final neLng = position.longitude + delta;
        final latitudeDelta = neLat - swLat;

        await tileProvider!.loadTilesForViewport(
          swLat: swLat,
          swLng: swLng,
          neLat: neLat,
          neLng: neLng,
          latitudeDelta: latitudeDelta,
          locale: 'es',
          bufferSize:
              0, // Sin buffer para carga inicial - solo el tile necesario
        );

        // Obtener eventos del provider
        final events = tileProvider!.allEvents;

        // Calcular distancia desde el usuario para cada evento
        final eventsWithDistance = events.map((event) {
          final distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            event.latitude,
            event.longitude,
          );
          final distanceInKm = distanceInMeters / 1000;
          return event.copyWith(distance: distanceInKm);
        }).toList();

        // Ordenar por distancia
        eventsWithDistance.sort((a, b) {
          final distanceA = a.distance ?? double.maxFinite;
          final distanceB = b.distance ?? double.maxFinite;
          return distanceA.compareTo(distanceB);
        });

        AppLogger.info(
          '[HomeBloc] LoadNearbyEvents (tiles) SUCCESS: Loaded ${eventsWithDistance.length} events',
        );

        if (!emit.isDone) {
          emit(
            state.copyWith(
              isLoading: false,
              allEvents: eventsWithDistance,
              events: eventsWithDistance,
              markers: const {}, // ClusterManager creará los markers
              userLocation: userLocation,
              lastLoadedPosition: userLocation,
              lastZoomLevel: 14.0,
              hasLocationAccess: true,
              locationErrorType: null,
            ),
          );
        }
        return;
      }

      // FALLBACK: Si no hay tileProvider, usar endpoint de búsqueda
      // (Nota: Este endpoint parece tener un bug que omite algunos eventos)
      AppLogger.warning(
        '[HomeBloc] No tileProvider available, falling back to getNearbyEvents',
      );

      AppLogger.info('[HomeBloc] Calling getNearbyEvents with 20km radius...');

      final result = await getNearbyEvents(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 20000.0, // 20km de radio
      );

      await result.fold(
        (failure) async {
          AppLogger.error(
            '[HomeBloc] LoadNearbyEvents FAILED: ${failure.userMessage}',
            failure,
            null,
          );

          if (!emit.isDone) {
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: failure.userMessage,
                hasLocationAccess: true,
              ),
            );
          }
        },
        (events) async {
          // Ordenar eventos por distancia (más cercanos primero)
          final sortedEvents = [...events];
          sortedEvents.sort((a, b) {
            final distanceA = a.distance ?? double.maxFinite;
            final distanceB = b.distance ?? double.maxFinite;
            return distanceA.compareTo(distanceB);
          });

          AppLogger.info(
            '[HomeBloc] LoadNearbyEvents SUCCESS: Loaded ${sortedEvents.length} events within 20km radius',
          );

          if (sortedEvents.isEmpty) {
            AppLogger.warning(
              '[HomeBloc] WARNING: No events found within 20km of user location',
            );
          }

          if (!emit.isDone) {
            emit(
              state.copyWith(
                isLoading: false,
                allEvents: sortedEvents,
                events: sortedEvents,
                markers: const {}, // ClusterManager creará los markers
                userLocation: userLocation,
                lastLoadedPosition: userLocation,
                lastZoomLevel: 14.0,
                hasLocationAccess: true,
                locationErrorType: null,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      // Determinar el tipo de error de ubicación
      String? locationErrorType;
      if (e is LocationServiceDisabledException) {
        locationErrorType = 'disabled';
      } else if (e is LocationPermissionDeniedException) {
        locationErrorType = 'denied';
      } else if (e is LocationPermissionDeniedForeverException) {
        locationErrorType = 'deniedForever';
      }

      // Si es un error de ubicación conocido, cargar eventos sin filtro de ubicación
      if (locationErrorType != null) {
        AppLogger.warning(
          'Location access error: $locationErrorType. Loading all events without location filter.',
        );

        try {
          // Cargar eventos usando bounds muy grandes (ejemplo: toda España o área predeterminada)
          // Coordenadas aproximadas de España como fallback
          const defaultSwLat = 36.0; // Sur de España
          const defaultSwLng = -9.0; // Oeste de España
          const defaultNeLat = 44.0; // Norte de España
          const defaultNeLng = 4.0; // Este de España

          final result = await getEventsForMapBounds(
            swLat: defaultSwLat,
            swLng: defaultSwLng,
            neLat: defaultNeLat,
            neLng: defaultNeLng,
          );

          await result.fold(
            (failure) async {
              if (!emit.isDone) {
                emit(
                  state.copyWith(
                    isLoading: false,
                    errorMessage: failure.userMessage,
                    hasLocationAccess: false,
                    locationErrorType: locationErrorType,
                  ),
                );
              }
            },
            (events) async {
              // Usar una ubicación por defecto para centrar el mapa (centro de España)
              const defaultLocation = LatLng(40.4168, -3.7038); // Madrid

              if (!emit.isDone) {
                emit(
                  state.copyWith(
                    isLoading: false,
                    allEvents: events,
                    events: events,
                    userLocation: defaultLocation,
                    lastLoadedPosition: defaultLocation,
                    lastZoomLevel: 6.0,
                    hasLocationAccess: false,
                    locationErrorType: locationErrorType,
                    errorMessage:
                        null, // Limpiar mensaje de error ya que cargamos exitosamente
                  ),
                );
              }
            },
          );
        } catch (fallbackError, fallbackStackTrace) {
          AppLogger.error(
            'Error loading events without location',
            fallbackError,
            fallbackStackTrace,
          );
          if (!emit.isDone) {
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: _getLocationErrorMessage(e),
                hasLocationAccess: false,
                locationErrorType: locationErrorType,
              ),
            );
          }
        }
      } else {
        // Error no relacionado con ubicación
        AppLogger.error('Error loading nearby events', e, stackTrace);
        if (!emit.isDone) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: _getLocationErrorMessage(e),
              hasLocationAccess: false,
            ),
          );
        }
      }
    } finally {
      _loadNearbyEventsInProgress = false;
    }
  }

  Future<void> _onSelectEventMarker(
    SelectEventMarker event,
    Emitter<HomeState> emit,
  ) async {
    // Detectar eventos colocalizados (en las mismas coordenadas o muy cercanos)
    List<Event> colocatedEvents = _findColocatedEvents(
      event.event,
      state.events,
    );

    // Recalcular distancia de eventos colocalizados con ubicación actual del usuario
    if (state.userLocation != null && state.hasLocationAccess) {
      colocatedEvents = colocatedEvents.map((e) {
        final distanceInMeters = Geolocator.distanceBetween(
          state.userLocation!.latitude,
          state.userLocation!.longitude,
          e.latitude,
          e.longitude,
        );
        final distanceInKm = distanceInMeters / 1000;
        return e.copyWith(distance: distanceInKm);
      }).toList();
    }

    AppLogger.info(
      '[HomeBloc] SelectEventMarker: ${event.event.id}, found ${colocatedEvents.length} colocated events: ${colocatedEvents.map((e) => '${e.id}(dist:${e.distance?.toStringAsFixed(1)})').join(', ')}',
    );

    emit(
      state.copyWith(
        selectedEvent: colocatedEvents.isNotEmpty
            ? colocatedEvents[0]
            : event.event,
        colocatedEvents: colocatedEvents,
        colocatedEventIndex: 0, // Seleccionar el primero
      ),
    );
  }

  Future<void> _onDeselectEvent(
    DeselectEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedEvent: null,
        colocatedEvents: const [],
        colocatedEventIndex: 0,
      ),
    );
  }

  Future<void> _onRefreshEvents(
    RefreshEvents event,
    Emitter<HomeState> emit,
  ) async {
    add(const LoadNearbyEvents());
  }

  void _onBlockedUsersChanged(
    HomeBlockedUsersChanged event,
    Emitter<HomeState> emit,
  ) {
    if (tileProvider == null) return;
    // allEvents ya filtra promotores bloqueados internamente
    final freshEvents = tileProvider!.allEvents;
    final filtered = _applyFiltersAndSearch(
      events: freshEvents,
      searchQuery: state.searchQuery,
      startDate: state.filterStartDate,
      endDate: state.filterEndDate,
      categories: state.filterCategories,
      onlyFree: state.filterOnlyFree,
      minPrice: state.filterMinPrice,
      maxPrice: state.filterMaxPrice,
    );
    emit(
      state.copyWith(
        allEvents: freshEvents,
        events: filtered,
        visibleEvents: filtered,
      ),
    );
  }

  Future<void> _onZoomToCluster(
    ZoomToCluster event,
    Emitter<HomeState> emit,
  ) async {
    // LÓGICA INTELIGENTE según documento:
    // 1. Detectar si el cluster tiene eventos co-ubicados (bounds < 0.0001°)
    // 2. Si co-ubicados + zoom < 16: hacer zoom +2 (máx 16)
    // 3. Si co-ubicados + zoom >= 16: abrir card con navegación
    // 4. Si dispersos: fitBounds con límite zoom 16

    // Calcular bounds del cluster
    if (event.clusterEvents.isEmpty) return;

    final latitudes = event.clusterEvents.map((e) => e.latitude).toList();
    final longitudes = event.clusterEvents.map((e) => e.longitude).toList();

    final minLat = latitudes.reduce((a, b) => a < b ? a : b);
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    final minLng = longitudes.reduce((a, b) => a < b ? a : b);
    final maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    final latDiff = (maxLat - minLat).abs();
    final lngDiff = (maxLng - minLng).abs();

    const threshold = 0.0001; // 0.0001° ≈ 11 metros
    const maxZoom = 16.0;

    final areColocated = latDiff < threshold && lngDiff < threshold;

    if (areColocated) {
      // Eventos en la misma ubicación
      if (event.currentZoom >= maxZoom) {
        // Ya estamos en zoom máximo → abrir card con navegación
        AppLogger.info(
          '[HomeBloc] Cluster co-ubicado en zoom máximo → abrir card con navegación',
        );

        // Encontrar eventos colocalizados
        final colocatedEvents = _findColocatedEvents(
          event.clusterEvents.first,
          event.clusterEvents,
        );

        emit(
          state.copyWith(
            selectedEvent: colocatedEvents.first,
            colocatedEvents: colocatedEvents,
            colocatedEventIndex: 0,
          ),
        );
      } else {
        // Hacer zoom +2 (máximo 16)
        final newZoomLevel = (event.currentZoom + 2).clamp(0.0, maxZoom);

        AppLogger.info(
          '[HomeBloc] Cluster co-ubicado → hacer zoom +2 hasta $newZoomLevel',
        );

        emit(
          state.copyWith(
            zoomToPosition: event.center,
            zoomToLevel: newZoomLevel,
          ),
        );

        // Limpiar inmediatamente el zoom target
        emit(state.copyWith(zoomToPosition: null, zoomToLevel: null));
      }
    } else {
      // Eventos dispersos → fitBounds con límite zoom 16
      // El límite de zoom se maneja en HomePage después del fitBounds
      AppLogger.info(
        '[HomeBloc] Cluster disperso → fitBounds con límite zoom $maxZoom',
      );

      emit(
        state.copyWith(
          zoomToPosition: event.center,
          zoomToLevel: null, // null indica que debe hacer fitBounds
          // Guardar bounds para fitBounds (se necesita en HomePage)
        ),
      );

      // Limpiar inmediatamente
      emit(state.copyWith(zoomToPosition: null, zoomToLevel: null));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Deduplicate: if a permission dialog is already showing, await the same
      // Future instead of starting a second request (iOS would throw
      // PermissionRequestInProgressException).
      _permissionRequest ??= Geolocator.requestPermission().whenComplete(() {
        _permissionRequest = null;
      });
      permission = await _permissionRequest!;
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException();
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  String _getLocationErrorMessage(dynamic error) {
    if (error is LocationServiceDisabledException) {
      return 'errorLocationDisabled';
    } else if (error is LocationPermissionDeniedException) {
      return 'errorLocationDenied';
    } else if (error is LocationPermissionDeniedForeverException) {
      return 'errorLocationDeniedForever';
    } else {
      return 'errorLoadingEvents';
    }
  }

  Future<void> _onSearchEvents(
    SearchEvents event,
    Emitter<HomeState> emit,
  ) async {
    final query = event.query.toLowerCase().trim();

    // Aplicar filtros actuales + búsqueda
    final filteredEvents = _applyFiltersAndSearch(
      events: state.allEvents,
      searchQuery: query,
      startDate: state.filterStartDate,
      endDate: state.filterEndDate,
      categories: state.filterCategories,
      onlyFree: state.filterOnlyFree,
      minPrice: state.filterMinPrice,
      maxPrice: state.filterMaxPrice,
    );

    emit(
      state.copyWith(
        searchQuery: query,
        events: filteredEvents,
        visibleEvents: filteredEvents,
      ),
    );
  }

  Future<void> _onFilterEvents(
    FilterEvents event,
    Emitter<HomeState> emit,
  ) async {
    // Aplicar búsqueda actual + nuevos filtros
    final filteredEvents = _applyFiltersAndSearch(
      events: state.allEvents,
      searchQuery: state.searchQuery,
      startDate: event.startDate,
      endDate: event.endDate,
      categories: event.categories,
      onlyFree: event.onlyFree,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
    );

    emit(
      state.copyWith(
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
        filterCategories: event.categories,
        filterOnlyFree: event.onlyFree,
        filterMinPrice: event.minPrice,
        filterMaxPrice: event.maxPrice,
        events: filteredEvents,
        visibleEvents: filteredEvents,
      ),
    );
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<HomeState> emit,
  ) async {
    // Mantener solo la búsqueda, limpiar filtros
    final filteredEvents = _applyFiltersAndSearch(
      events: state.allEvents,
      searchQuery: state.searchQuery,
      startDate: null,
      endDate: null,
      categories: null,
      onlyFree: null,
      minPrice: null,
      maxPrice: null,
    );

    emit(
      state.copyWith(
        filterStartDate: null,
        filterEndDate: null,
        filterCategories: null,
        filterOnlyFree: null,
        filterMinPrice: null,
        filterMaxPrice: null,
        events: filteredEvents,
        visibleEvents: filteredEvents,
      ),
    );
  }

  List<Event> _applyFiltersAndSearch({
    required List<Event> events,
    required String searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    bool? onlyFree,
    double? minPrice,
    double? maxPrice,
  }) {
    // Copiar siempre para evitar mutar la lista no modificable de Equatable
    var filtered = [...events];

    // Aplicar búsqueda de texto
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        final titleMatch = event.title.toLowerCase().contains(searchQuery);
        final descriptionMatch =
            event.description?.toLowerCase().contains(searchQuery) ?? false;
        final venueNameMatch =
            event.venueName?.toLowerCase().contains(searchQuery) ?? false;
        final categorySlugMatch =
            event.categorySlug?.toLowerCase().contains(searchQuery) ?? false;

        return titleMatch ||
            descriptionMatch ||
            venueNameMatch ||
            categorySlugMatch;
      }).toList();
    }

    // Aplicar filtro de fecha de inicio
    if (startDate != null) {
      filtered = filtered.where((event) {
        return event.startDate.isAfter(startDate) ||
            event.startDate.isAtSameMomentAs(startDate);
      }).toList();
    }

    // Aplicar filtro de fecha de fin
    if (endDate != null) {
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      filtered = filtered.where((event) {
        return event.startDate.isBefore(endOfDay) ||
            event.startDate.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    // Aplicar filtro de categorías (selección múltiple)
    if (categories != null && categories.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.categorySlug != null &&
            categories.contains(event.categorySlug);
      }).toList();
    }

    // Aplicar filtro de eventos gratuitos
    if (onlyFree == true) {
      filtered = filtered.where((event) {
        return event.price == null || event.price == 0.0;
      }).toList();
    } else {
      // Solo aplicar filtros de precio si no está activo "solo gratuitos"
      // Aplicar filtro de precio mínimo
      if (minPrice != null) {
        filtered = filtered.where((event) {
          return event.price != null && event.price! >= minPrice;
        }).toList();
      }

      // Aplicar filtro de precio máximo
      if (maxPrice != null) {
        filtered = filtered.where((event) {
          return event.price != null && event.price! <= maxPrice;
        }).toList();
      }
    }

    // Ordenar por distancia si hay ubicación, por nombre si no
    if (filtered.any((e) => e.distance != null)) {
      filtered.sort((a, b) {
        final distanceA = a.distance ?? double.maxFinite;
        final distanceB = b.distance ?? double.maxFinite;
        return distanceA.compareTo(distanceB);
      });
    } else {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    }

    return filtered;
  }

  /// Calcula la distancia en kilómetros entre dos coordenadas usando la fórmula de Haversine
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Carga tiles usando el EventTileProvider (nuevo sistema)
  Future<void> _onLoadTilesForMapPosition(
    LoadTilesForMapPosition event,
    Emitter<HomeState> emit,
  ) async {
    if (tileProvider == null) {
      AppLogger.warning(
        'TileProvider no disponible, usando método tradicional',
      );
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Convertir categorías de slug a ID (si es necesario, depende del backend)
      List<String>? categoryIds;
      if (state.filterCategories != null &&
          state.filterCategories!.isNotEmpty) {
        // Por ahora asumimos que las categorías son slugs
        // El backend debe aceptar slugs o necesitamos un mapeo
        categoryIds = null; // Mapear slugs a IDs si el backend lo requiere
      }

      // Cargar tiles con filtros
      await tileProvider!.loadTilesForViewport(
        swLat: event.swLat,
        swLng: event.swLng,
        neLat: event.neLat,
        neLng: event.neLng,
        latitudeDelta: event.latitudeDelta,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        categories: categoryIds,
        dateFrom: state.filterStartDate,
        dateTo: state.filterEndDate,
        priceMin: state.filterOnlyFree == true ? 0.0 : state.filterMinPrice,
        priceMax: state.filterOnlyFree == true ? 0.0 : state.filterMaxPrice,
        bufferSize: event.bufferSize,
      );

      // Obtener eventos del provider
      final events = tileProvider!.allEvents;

      // Calcular distancia desde el usuario para cada evento
      List<Event> eventsWithDistance = events;
      if (state.userLocation != null && state.hasLocationAccess) {
        eventsWithDistance = events.map((event) {
          final distanceInMeters = Geolocator.distanceBetween(
            state.userLocation!.latitude,
            state.userLocation!.longitude,
            event.latitude,
            event.longitude,
          );
          final distanceInKm = distanceInMeters / 1000;
          return event.copyWith(distance: distanceInKm);
        }).toList();
      }

      // IMPORTANTE: Aplicar filtros del cliente sobre los eventos del backend
      // Esto es necesario porque el backend no soporta filtros múltiples de categoría
      // y necesitamos aplicar también la búsqueda de texto
      final filteredEvents = _applyFiltersAndSearch(
        events: eventsWithDistance,
        searchQuery: state.searchQuery,
        startDate: state.filterStartDate,
        endDate: state.filterEndDate,
        categories: state.filterCategories,
        onlyFree: state.filterOnlyFree,
        minPrice: state.filterMinPrice,
        maxPrice: state.filterMaxPrice,
      );

      // NO crear markers manualmente - dejar que ClusterManager lo haga
      // El ClusterManager en HomePage se encarga del clustering automático

      // Calcular centro del mapa
      final centerLat = (event.swLat + event.neLat) / 2;
      final centerLng = (event.swLng + event.neLng) / 2;

      if (!emit.isDone) {
        emit(
          state.copyWith(
            isLoading: false,
            allEvents: eventsWithDistance,
            events: filteredEvents, // Usar eventos filtrados
            // NO emitir markers - HomePage los creará con ClusterManager
            markers: const {},
            lastLoadedPosition: LatLng(centerLat, centerLng),
            lastZoomLevel: tileProvider!.currentZoom.toDouble(),
            selectedEvent: state.selectedEvent,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error loading tiles for map position', e, stackTrace);
      if (!emit.isDone) {
        emit(
          state.copyWith(isLoading: false, errorMessage: 'errorLoadingEvents'),
        );
      }
    }
  }

  /// Navegar al siguiente evento colocalizado
  Future<void> _onNextColocatedEvent(
    NextColocatedEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state.colocatedEvents.isEmpty) return;

    final nextIndex =
        (state.colocatedEventIndex + 1) % state.colocatedEvents.length;
    final nextEvent = state.colocatedEvents[nextIndex];

    AppLogger.info(
      '[HomeBloc] Next colocated event: ${nextEvent.id} (${nextIndex + 1}/${state.colocatedEvents.length}), distance: ${nextEvent.distance?.toStringAsFixed(1)}',
    );

    emit(
      state.copyWith(selectedEvent: nextEvent, colocatedEventIndex: nextIndex),
    );
  }

  /// Navegar al evento colocalizado anterior
  Future<void> _onPreviousColocatedEvent(
    PreviousColocatedEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state.colocatedEvents.isEmpty) return;

    final prevIndex =
        (state.colocatedEventIndex - 1 + state.colocatedEvents.length) %
        state.colocatedEvents.length;
    final prevEvent = state.colocatedEvents[prevIndex];

    AppLogger.info(
      '[HomeBloc] Previous colocated event: ${prevEvent.id} (${prevIndex + 1}/${state.colocatedEvents.length}), distance: ${prevEvent.distance?.toStringAsFixed(1)}',
    );

    emit(
      state.copyWith(selectedEvent: prevEvent, colocatedEventIndex: prevIndex),
    );
  }

  void _onUpdateVisibleEvents(
    UpdateVisibleEvents event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(visibleEvents: event.visibleEvents));
  }

  /// Encuentra eventos que están en las mismas coordenadas o muy cercanos
  /// Usa un radio de 20 metros para considerar eventos como colocalizados
  List<Event> _findColocatedEvents(Event targetEvent, List<Event> allEvents) {
    const maxDistanceKm = 0.02; // 20 metros
    final colocated = <Event>[];

    for (final event in allEvents) {
      final distance = _calculateDistance(
        targetEvent.latitude,
        targetEvent.longitude,
        event.latitude,
        event.longitude,
      );

      if (distance <= maxDistanceKm) {
        colocated.add(event);
      }
    }

    // Ordenar por fecha de inicio (eventos más próximos primero)
    colocated.sort((a, b) => a.startDate.compareTo(b.startDate));

    return colocated;
  }
}

// Excepciones personalizadas de ubicación
class LocationServiceDisabledException implements Exception {}

class LocationPermissionDeniedException implements Exception {}

class LocationPermissionDeniedForeverException implements Exception {}
