// lib/features/discovery/presentation/pages/category_events_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/discovery/data/datasources/events_remote_data_source.dart';
import 'package:wap_app/features/discovery/data/models/category_model.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/home/presentation/widgets/event_list_card.dart';
import 'package:wap_app/shared/widgets/custom_app_bar.dart';
import 'package:geolocator/geolocator.dart';

class CategoryEventsPage extends StatefulWidget {
  final CategoryModel category;
  final LatLng? userLocation;

  const CategoryEventsPage({
    super.key,
    required this.category,
    this.userLocation,
  });

  @override
  State<CategoryEventsPage> createState() => _CategoryEventsPageState();
}

class _CategoryEventsPageState extends State<CategoryEventsPage> {
  final EventsRemoteDataSource _eventsDataSource = EventsRemoteDataSourceImpl(
    dio: sl<Dio>(),
  );

  final List<Event> events = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? error;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _initializeUserLocation();
    _loadEvents();
  }

  Future<void> _initializeUserLocation() async {
    // Intentar obtener la ubicación del widget o del HomeBloc (solo si tiene acceso)
    final homeBloc = sl<HomeBloc>();
    _userLocation =
        widget.userLocation ??
        (homeBloc.state.hasLocationAccess ? homeBloc.state.userLocation : null);

    // Si aún no hay ubicación, verificar permiso SIN solicitarlo
    if (_userLocation == null) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          return; // Sin permiso: no calcular distancias
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          ),
        );

        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });

        // Recalcular distancias localmente en los eventos ya cargados,
        // sin lanzar una segunda petición de red.
        if (events.isNotEmpty) {
          final updated = events.map((event) {
            final distance =
                Geolocator.distanceBetween(
                  _userLocation!.latitude,
                  _userLocation!.longitude,
                  event.latitude,
                  event.longitude,
                ) /
                1000;
            return event.copyWith(distance: distance);
          }).toList();
          updated.sort((a, b) {
            final distA = a.distance ?? double.infinity;
            final distB = b.distance ?? double.infinity;
            return distA.compareTo(distB);
          });
          setState(() {
            events
              ..clear()
              ..addAll(updated);
          });
        }
      } catch (e) {
        // Error obteniendo ubicación
      }
    }
  }

  Future<void> _loadEvents({bool refresh = false}) async {
    if (isLoading || (!hasMore && !refresh)) return;

    setState(() {
      isLoading = true;
      error = null;
      if (refresh) {
        events.clear();
        currentPage = 1;
        hasMore = true;
      }
    });

    try {
      final response = await _eventsDataSource.getEventsByCategory(
        widget.category.slug,
        page: currentPage,
        limit: 20,
      );

      // Calcular distancia si tenemos la ubicación del usuario

      final List<Event> eventsWithDistance = response.data.map((event) {
        if (_userLocation != null) {
          final distance =
              Geolocator.distanceBetween(
                _userLocation!.latitude,
                _userLocation!.longitude,
                event.latitude,
                event.longitude,
              ) /
              1000; // Convertir a kilómetros
          return event.copyWith(distance: distance);
        }
        return event;
      }).toList();

      // Ordenar por distancia si hay ubicación, por nombre si no
      if (_userLocation != null) {
        eventsWithDistance.sort((a, b) {
          final distA = a.distance ?? double.infinity;
          final distB = b.distance ?? double.infinity;
          return distA.compareTo(distB);
        });
      } else {
        eventsWithDistance.sort((a, b) => a.title.compareTo(b.title));
      }

      // Filtrar eventos de promotores bloqueados
      final blockedUsersService = sl<BlockedUsersService>();
      final filtered = eventsWithDistance.where((event) {
        final pid = event.promoterId;
        return pid == null || !blockedUsersService.isBlocked(pid);
      }).toList();

      setState(() {
        events.addAll(filtered);
        currentPage++;
        hasMore = response.meta.page < response.meta.totalPages;
      });
    } catch (e) {
      setState(() {
        error = context.l10n.categoryPlansError;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color get categoryColor {
    try {
      return Color(int.parse(widget.category.color.replaceFirst('#', '0xff')));
    } catch (e) {
      return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.category.name, showBackButton: true),
      body: RefreshIndicator(
        onRefresh: () => _loadEvents(refresh: true),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadEvents(refresh: true),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: context.colorScheme.onSurface.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.categoryPlansEmpty,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.categoryPlansEmptyBody,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface.withAlpha(170),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: events.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == events.length) {
          // Cargar más al llegar al final
          if (!isLoading) _loadEvents();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final event = events[index];
        return EventListCard(event: event);
      },
    );
  }
}
