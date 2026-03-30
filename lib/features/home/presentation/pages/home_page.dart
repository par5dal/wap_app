// lib/features/events/presentation/pages/home_page.dart

import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/constants/map_styles.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/core/utils/map_marker_helper.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/home/presentation/pages/events_list_page.dart';
import 'package:wap_app/features/home/presentation/widgets/event_detail_card.dart';
import 'package:wap_app/features/home/presentation/widgets/filter_overlay.dart';
import 'package:wap_app/features/home/presentation/widgets/map_toolbar.dart';
import 'package:wap_app/features/home/presentation/widgets/search_bar_with_filters.dart';
import 'package:wap_app/features/home/presentation/widgets/tile_debug_info.dart';
import 'package:wap_app/features/home/presentation/utils/manual_cluster_manager.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/shared/widgets/loading_overlay.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'dart:math' show cos, sqrt, asin, min;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        // Verificar si el usuario está autenticado
        final isAuthenticated = appState.status == AuthStatus.authenticated;

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => sl<HomeBloc>()..add(const LoadNearbyEvents()),
            ),
            // Usar el ProfileBloc singleton si el usuario está autenticado
            if (isAuthenticated) BlocProvider.value(value: sl<ProfileBloc>()),
          ],
          child: const HomePageView(),
        );
      },
    );
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  bool _hasMovedToUserLocation = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _mapMoveDebounce;
  LatLng? _lastCameraPosition;
  ManualClusterManager? _manualClusterManager;
  Set<Marker> _markers = {};

  // Cache de eventos para detectar cambios reales
  List<String> _lastEventIds = [];

  // Zoom actual
  double _currentZoom = 14.0;

  // Last known location permission — used to detect grant/revoke on resume
  LocationPermission? _lastLocationPermission;

  // Variable para detectar cuando se deselecciona un evento
  bool _hadSelectedEvent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationPermission();

    // Limpiar caché de markers para forzar regeneración con nuevos tamaños
    MapMarkerHelper.clearCache();

    // Crear el manual cluster manager
    _manualClusterManager = ManualClusterManager(
      onMarkersChanged: _updateMarkers,
      onMarkerTap: _onMarkerTap,
      onClusterTap: _onClusterTap,
    );

    AppLogger.info('[HomePage] Manual ClusterManager initialized');

    // Escuchar cambios en la lista de bloqueados para actualizar el mapa
    sl<BlockedUsersService>().addListener(_onBlockedUsersServiceChanged);

    // If HomeBloc already has events loaded (e.g. after registration rebuilds this state),
    // push them to the cluster manager on the next frame when context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _manualClusterManager?.pixelRatio = MediaQuery.of(
        context,
      ).devicePixelRatio;
      final events = context.read<HomeBloc>().state.events;
      if (events.isNotEmpty) {
        _lastEventIds = events.map((e) => e.id).toList()..sort();
        _manualClusterManager?.setEvents(events, _currentZoom);
      }
      // Request notification permission after home page loads (only if authenticated
      // and permission not yet determined — iOS won't show dialog if already decided)
      _requestNotificationPermissionIfNeeded();
    });
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    if (!mounted) return;
    final isAuth =
        context.read<AppBloc>().state.status == AuthStatus.authenticated;
    if (!isAuth) return;
    final status = await Permission.notification.status;
    // isDenied = not yet asked on iOS; don't prompt if blocked (permanently denied)
    if (status.isDenied && mounted) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) await Permission.notification.request();
    }
  }

  void _updateMarkers(Set<Marker> markers) {
    if (!mounted) return;
    setState(() {
      _markers = markers;
    });
  }

  Future<void> _onMarkerTap(Event event) async {
    if (!mounted) return;
    // Center the map on the tapped marker, zooming in to individual-marker level
    // if needed, before opening the card.
    final currentZoom = await _mapController?.getZoomLevel() ?? _currentZoom;
    final targetZoom = currentZoom < 17.0 ? 17.0 : currentZoom;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(event.latitude, event.longitude),
        targetZoom,
      ),
    );
    // Give the camera animation time to finish (~500 ms) before showing the card.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      context.read<HomeBloc>().add(SelectEventMarker(event));
    }
  }

  void _onClusterTap(EventCluster cluster) async {
    final currentZoom = await _mapController?.getZoomLevel() ?? 10;

    // Calcular bounds del cluster
    final latitudes = cluster.events.map((e) => e.latitude).toList();
    final longitudes = cluster.events.map((e) => e.longitude).toList();

    final minLat = latitudes.reduce((a, b) => a < b ? a : b);
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    final minLng = longitudes.reduce((a, b) => a < b ? a : b);
    final maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    final latDiff = (maxLat - minLat).abs();
    final lngDiff = (maxLng - minLng).abs();

    const threshold = 0.0001; // ≈11 metros
    final areColocated = latDiff < threshold && lngDiff < threshold;

    if (areColocated) {
      // Eventos co-ubicados (misma ubicación)
      if (currentZoom >= 17) {
        // Ya estamos en zoom adecuado → centrar y abrir card
        final event = cluster.events.first;
        if (mounted) {
          await _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, currentZoom),
          );
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.read<HomeBloc>().add(SelectEventMarker(event));
          }
        }
      } else {
        // Hacer zoom IN hacia el cluster (+3 niveles, máx 17)
        final newZoom = min(currentZoom + 3, 17.0);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(cluster.location, newZoom),
        );
      }
    } else {
      // Eventos dispersos → SIEMPRE hacer zoom IN gradualmente
      // Acercar +2 niveles hasta llegar a zoom 14 (donde se desclustera)
      final targetZoom = min(currentZoom + 2, 14.0);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.location, targetZoom),
      );
    }
  }

  @override
  void dispose() {
    _manualClusterManager?.dispose();
    sl<BlockedUsersService>().removeListener(_onBlockedUsersServiceChanged);
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _searchController.dispose();
    _mapMoveDebounce?.cancel();
    super.dispose();
  }

  void _onBlockedUsersServiceChanged() {
    if (mounted) {
      context.read<HomeBloc>().add(const HomeBlockedUsersChanged());
    }
  }

  Future<void> _initLocationPermission() async {
    _lastLocationPermission = await Geolocator.checkPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkLocationPermissionChange();
  }

  Future<void> _checkLocationPermissionChange() async {
    final current = await Geolocator.checkPermission();
    final prev = _lastLocationPermission;
    _lastLocationPermission = current;
    if (prev == null) return;

    final wasGranted =
        prev == LocationPermission.always ||
        prev == LocationPermission.whileInUse;
    final isGranted =
        current == LocationPermission.always ||
        current == LocationPermission.whileInUse;

    if (wasGranted != isGranted && mounted) {
      context.read<HomeBloc>().add(const LoadNearbyEvents());
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    // CRÍTICO: Forzar actualización si ya hay eventos cargados
    final homeBloc = context.read<HomeBloc>();
    final currentEvents = homeBloc.state.events;
    if (currentEvents.isNotEmpty) {
      AppLogger.info(
        '[HomePage] Map created with ${currentEvents.length} events already loaded. Forcing update.',
      );
      _lastEventIds = currentEvents.map((e) => e.id).toList()..sort();
      await _manualClusterManager?.setEvents(currentEvents, _currentZoom);
    }
  }

  void _centerOnUserLocation(LatLng? userLocation) {
    if (_mapController != null && userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 14.0),
      );
    }
  }

  void _handleSearch(String query) {
    context.read<HomeBloc>().add(SearchEvents(query));
  }

  /// Se llama cuando el usuario empieza a mover el mapa (pan/zoom)
  void _onCameraMoveStarted() {
    final state = context.read<HomeBloc>().state;
    // Cerrar la card si está abierta
    if (state.selectedEvent != null) {
      context.read<HomeBloc>().add(const DeselectEvent());
    }
  }

  void _onCameraMove(CameraPosition position) async {
    final bloc = context.read<HomeBloc>();
    final state = bloc.state;

    final newZoom = position.zoom;

    // Actualizar _currentZoom ANTES del await para que cualquier lectura de
    // _currentZoom durante la operación asíncrona (p.ej. BlocConsumer listener
    // llamando setEvents) vea el zoom correcto y no el valor anterior.
    _currentZoom = newZoom;

    // No actualizar clusters si hay un evento seleccionado (card abierto)
    // Esto evita que la card se cierre cuando el usuario mueve ligeramente el mapa
    if (state.selectedEvent == null) {
      // Actualizar zoom en el manual cluster manager
      await _manualClusterManager?.updateZoom(newZoom);
    }

    // Cancelar el timer anterior si existe
    _mapMoveDebounce?.cancel();

    // Crear un nuevo timer con debounce de 600ms (optimizado para tiles)
    _mapMoveDebounce = Timer(const Duration(milliseconds: 600), () {
      _checkAndLoadEventsForNewPosition(position);
      // Solo actualizar eventos visibles si NO hay un evento seleccionado
      // para evitar sobrescribir el estado durante la navegación de eventos colocalizados
      if (context.read<HomeBloc>().state.selectedEvent == null) {
        _updateVisibleEvents();
      }
    });
  }

  Future<void> _checkAndLoadEventsForNewPosition(
    CameraPosition position,
  ) async {
    final bloc = context.read<HomeBloc>();
    final state = bloc.state;

    // No recargar eventos si hay un evento seleccionado (card abierto)
    if (state.selectedEvent != null) {
      _lastCameraPosition = position.target;
      return;
    }

    final newPosition = position.target;
    final newZoom = position.zoom;

    // Si es la primera vez, guardar y salir
    if (_lastCameraPosition == null) {
      _lastCameraPosition = newPosition;
      return;
    }

    // Calcular distancia desde la última posición cargada
    final lastLoaded = state.lastLoadedPosition ?? state.userLocation;
    if (lastLoaded == null) return;

    final distance = _calculateDistance(
      lastLoaded.latitude,
      lastLoaded.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    // Calcular diferencia de zoom
    final lastZoom = state.lastZoomLevel ?? 14.0;
    final zoomDifference = (newZoom - lastZoom).abs();

    // Recargar si:
    // - Se movió más de 500 metros
    // - O el zoom cambió significativamente (±2 niveles)
    if (distance > 500 || zoomDifference >= 2) {
      // Calcular los bounds del mapa visible
      final bounds = await _getVisibleMapBounds();

      if (bounds != null) {
        if (!mounted) return;
        // USAR SISTEMA DE TILES (optimizado con caché)
        final latitudeDelta = bounds['neLat']! - bounds['swLat']!;

        bloc.add(
          LoadTilesForMapPosition(
            swLat: bounds['swLat']!,
            swLng: bounds['swLng']!,
            neLat: bounds['neLat']!,
            neLng: bounds['neLng']!,
            latitudeDelta: latitudeDelta,
            bufferSize:
                0, // Sin buffer inicial (se puede ajustar a 1 para prefetch)
          ),
        );
      }
    }

    _lastCameraPosition = newPosition;
  }

  /// Obtiene los bounds (límites) del área visible del mapa
  Future<Map<String, double>?> _getVisibleMapBounds() async {
    if (_mapController == null) return null;

    try {
      final bounds = await _mapController!.getVisibleRegion();
      return {
        'swLat': bounds.southwest.latitude,
        'swLng': bounds.southwest.longitude,
        'neLat': bounds.northeast.latitude,
        'neLng': bounds.northeast.longitude,
      };
    } catch (e) {
      return null;
    }
  }

  /// Actualiza los eventos visibles en el viewport actual
  Future<void> _updateVisibleEvents() async {
    if (!mounted) return;
    final homeBloc = context.read<HomeBloc>();
    final allEvents = homeBloc.state.events;

    final bounds = await _getVisibleMapBounds();
    if (bounds == null) return;

    // Filtrar eventos que están dentro del viewport
    final visibleEvents = allEvents.where((event) {
      return event.latitude >= bounds['swLat']! &&
          event.latitude <= bounds['neLat']! &&
          event.longitude >= bounds['swLng']! &&
          event.longitude <= bounds['neLng']!;
    }).toList();

    // Actualizar el estado con los eventos visibles
    homeBloc.add(UpdateVisibleEvents(visibleEvents));

    AppLogger.info(
      '[HomePage] Visible events updated: ${visibleEvents.length}/${allEvents.length}',
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Fórmula de Haversine para calcular distancia en metros
    const p = 0.017453292519943295; // Math.PI / 180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 *
        asin(sqrt(a)) *
        1000; // 2 * R; R = 6371 km, resultado en metros
  }

  /// Recarga forzada del mapa: limpia la caché de tiles y vuelve a cargar
  /// el área visible actual. Si el mapa aún no tiene bounds conocidos cae
  /// al flujo normal de LoadNearbyEvents.
  Future<void> _refreshMap() async {
    final bloc = context.read<HomeBloc>();
    // Limpiar caché HTTP (Hive) para forzar peticiones reales al servidor
    await sl<HiveCacheStore>().clean();
    // Limpiar caché de tiles en memoria
    bloc.tileProvider?.clearCache();
    final bounds = await _getVisibleMapBounds();
    if (!mounted) return;
    if (bounds != null) {
      final latitudeDelta = bounds['neLat']! - bounds['swLat']!;
      bloc.add(
        LoadTilesForMapPosition(
          swLat: bounds['swLat']!,
          swLng: bounds['swLng']!,
          neLat: bounds['neLat']!,
          neLng: bounds['neLng']!,
          latitudeDelta: latitudeDelta,
        ),
      );
    } else {
      bloc.add(const LoadNearbyEvents());
    }
  }

  void _showFilterOverlay() {
    final bloc = context.read<HomeBloc>();
    final currentState = bloc.state;

    // Extraer categorías únicas de todos los eventos cargados
    final availableCategories =
        currentState.allEvents
            .where((event) => event.categorySlug != null)
            .map((event) => event.categorySlug!)
            .toSet()
            .toList()
          ..sort(); // Ordenar alfabéticamente

    // Mapa de SVG por slug de categoría (mismo que usan los markers del mapa)
    final categorySvgMap = <String, String?>{};
    for (final event in currentState.allEvents) {
      if (event.categorySlug != null &&
          !categorySvgMap.containsKey(event.categorySlug)) {
        categorySvgMap[event.categorySlug!] = event.categorySvg;
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withAlpha(51),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
            ),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                alignment: Alignment.topLeft,
                child: FilterOverlay(
                  selectedStartDate: currentState.filterStartDate,
                  selectedEndDate: currentState.filterEndDate,
                  selectedCategories: currentState.filterCategories,
                  onlyFree: currentState.filterOnlyFree,
                  minPrice: currentState.filterMinPrice,
                  maxPrice: currentState.filterMaxPrice,
                  availableCategories: availableCategories,
                  categorySvgMap: categorySvgMap,
                  onApply: (filters) {
                    bloc.add(
                      FilterEvents(
                        startDate: filters['startDate'],
                        endDate: filters['endDate'],
                        categories: filters['categories'],
                        onlyFree: filters['onlyFree'],
                        minPrice: filters['minPrice'],
                        maxPrice: filters['maxPrice'],
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  onClear: () {
                    bloc.add(const ClearFilters());
                    Navigator.of(dialogContext).pop();
                  },
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showErrorSnackBar(state.errorMessage!);
        }

        // Log cuando cambie el evento seleccionado
        if (state.selectedEvent != null) {
          AppLogger.info(
            '[HomePage] Selected event updated: ${state.selectedEvent!.id} (index: ${state.colocatedEventIndex}/${state.colocatedEvents.length})',
          );
        }

        // Detectar cuando se cierra la card del evento
        if (_hadSelectedEvent && state.selectedEvent == null) {
          // Se acaba de deseleccionar un evento, recalcular clusters
          AppLogger.info(
            '[HomePage] Event deselected, recalculating clusters at zoom $_currentZoom',
          );
          _manualClusterManager?.updateZoom(_currentZoom);
        }
        _hadSelectedEvent = state.selectedEvent != null;

        // Actualizar el ManualClusterManager cuando cambien los eventos
        // Solo actualizar si los eventos realmente cambiaron (evita recreación innecesaria)
        final currentEventIds = state.events.map((e) => e.id).toList()..sort();
        final hasChanged =
            currentEventIds.length != _lastEventIds.length ||
            !currentEventIds.asMap().entries.every(
              (e) => e.value == _lastEventIds[e.key],
            );

        if (hasChanged) {
          _lastEventIds = currentEventIds;

          AppLogger.info(
            '[HomePage] Updating ManualClusterManager with ${state.events.length} events',
          );

          _manualClusterManager?.setEvents(state.events, _currentZoom);

          // Actualizar eventos visibles cuando cambien los eventos
          // Solo si NO hay un evento seleccionado para evitar conflictos
          if (state.selectedEvent == null) {
            _updateVisibleEvents();
          }
        }

        // Centrar automáticamente en la ubicación del usuario cuando se obtenga
        if (state.userLocation != null &&
            !_hasMovedToUserLocation &&
            _mapController != null) {
          _hasMovedToUserLocation = true;
          _centerOnUserLocation(state.userLocation);
        }

        // Hacer zoom hacia un cluster cuando se solicite
        if (state.zoomToPosition != null &&
            state.zoomToLevel != null &&
            _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              state.zoomToPosition!,
              state.zoomToLevel!,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset:
              false, // Evita el redimensionado en iOS que causa espacios blancos
          body: Stack(
            children: [
              // Mapa de Google Maps ocupando toda la pantalla
              GoogleMap(
                onMapCreated: _onMapCreated,
                style: Theme.of(context).brightness == Brightness.dark
                    ? MapStyles.darkMapStyle
                    : MapStyles.cleanMapStyle,
                onCameraMove: _onCameraMove,
                onCameraMoveStarted: _onCameraMoveStarted,
                initialCameraPosition: CameraPosition(
                  target:
                      state.userLocation ?? const LatLng(40.416775, -3.703790),
                  zoom: state.userLocation != null ? 14.0 : 5.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(
                  3.0, // Zoom mínimo: nivel multi-país
                  20.0, // Zoom máximo: nivel calle
                ),
                onTap: (_) {
                  if (state.selectedEvent != null) {
                    context.read<HomeBloc>().add(const DeselectEvent());
                  }
                },
              ),

              // Loading Overlay
              if (state.isLoading && state.events.isEmpty)
                LoadingOverlay(isLoading: state.isLoading, child: Container()),

              // Barra de búsqueda + botón de recarga (parte superior)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SearchBarWithFilters(
                        searchController: _searchController,
                        onFilterTap: _showFilterOverlay,
                        onSearchChanged: _handleSearch,
                        hasActiveFilters: state.hasActiveFilters,
                        mapboxAccessToken:
                            dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim() ?? '',
                        onLocationSelected: (latLng, locationName) async {
                          // Mover el mapa a la nueva ubicación con zoom fijo de 17
                          const zoomLevel = 17.0;
                          await _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(latLng, zoomLevel),
                          );

                          // Obtener los bounds del mapa y cargar eventos con sistema de tiles
                          final bounds = await _getVisibleMapBounds();
                          if (bounds != null) {
                            if (context.mounted) {
                              final latitudeDelta =
                                  bounds['neLat']! - bounds['swLat']!;

                              context.read<HomeBloc>().add(
                                LoadTilesForMapPosition(
                                  swLat: bounds['swLat']!,
                                  swLng: bounds['swLng']!,
                                  neLat: bounds['neLat']!,
                                  neLng: bounds['neLng']!,
                                  latitudeDelta: latitudeDelta,
                                  bufferSize: 0,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MapRefreshButton(
                      isLoading: state.isLoading,
                      onTap: () => _refreshMap(),
                    ),
                  ],
                ),
              ),

              // Loader pequeño de tiles con efecto rotando (sin blur)
              if (context.read<HomeBloc>().tileProvider?.isLoading == true)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 0,
                  right: 0,
                  child: const Center(child: _SimpleRotatingLoader()),
                ),

              // Card de detalle del evento (debajo de la barra de búsqueda)
              if (state.selectedEvent != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 88,
                  left: 16,
                  right: 16,
                  child: EventDetailCard(
                    key: ValueKey('event_${state.selectedEvent!.id}'),
                    event: state.selectedEvent!,
                    onClose: () {
                      context.read<HomeBloc>().add(const DeselectEvent());
                    },
                    // Navegación entre eventos colocalizados
                    colocatedCount: state.colocatedEvents.length > 1
                        ? state.colocatedEvents.length
                        : null,
                    colocatedIndex: state.colocatedEvents.length > 1
                        ? state.colocatedEventIndex
                        : null,
                    onPrevious: state.colocatedEvents.length > 1
                        ? () {
                            context.read<HomeBloc>().add(
                              const PreviousColocatedEvent(),
                            );
                          }
                        : null,
                    onNext: state.colocatedEvents.length > 1
                        ? () {
                            context.read<HomeBloc>().add(
                              const NextColocatedEvent(),
                            );
                          }
                        : null,
                  ),
                ),

              // Toolbar inferior
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: MapToolbar(
                  onListTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (newContext) => BlocProvider.value(
                          value: context.read<HomeBloc>(),
                          child: const EventsListPage(),
                        ),
                      ),
                    );
                  },
                  onLocationTap: () {
                    _centerOnUserLocation(state.userLocation);
                  },
                ),
              ),

              // Debug info de tiles (esquina inferior derecha, sobre la toolbar)
              TileDebugInfo(
                tileProvider: context.read<HomeBloc>().tileProvider,
                mapController: _mapController,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Loader simple con rotación pero sin efecto de blur
class _SimpleRotatingLoader extends StatefulWidget {
  const _SimpleRotatingLoader();

  @override
  State<_SimpleRotatingLoader> createState() => _SimpleRotatingLoaderState();
}

class _SimpleRotatingLoaderState extends State<_SimpleRotatingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color1 = theme.colorScheme.primary;
    final color2 = theme.colorScheme.secondary;

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Capa 1: Gradiente rotando con blur
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 56 * 0.15, sigmaY: 56 * 0.15),
            child: RotationTransition(
              turns: _controller,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color1, color2, color1.withAlpha(127)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Capa 2: Logo en el centro (sin blur)
          Image.asset(
            'assets/images/icon_light.png',
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

/// Botón circular flotante para recargar manualmente el mapa.
/// Muestra un spinner mientras hay carga en curso, y un icono de recarga
/// cuando el mapa está idle.
class _MapRefreshButton extends StatelessWidget {
  const _MapRefreshButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();
    return Material(
      shape: const CircleBorder(),
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    size: 22,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
          ),
        ),
      ),
    );
  }
}
