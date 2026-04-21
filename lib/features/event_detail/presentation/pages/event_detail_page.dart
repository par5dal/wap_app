// lib/features/event_detail/presentation/pages/event_detail_page.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/usecases/get_event_by_id.dart';
import 'package:wap_app/features/home/domain/usecases/record_event_view.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/promoter_profile/domain/usecases/get_promoter_profile.dart';
import 'package:wap_app/features/promoter_profile/presentation/pages/promoter_profile_page.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wap_app/core/services/analytics_service.dart';
import 'package:wap_app/shared/widgets/custom_button.dart';
import 'package:wap_app/shared/widgets/favorite_button.dart';
import 'package:wap_app/shared/widgets/follow_button.dart';
import 'package:wap_app/shared/widgets/glowing_logo.dart';
import 'package:wap_app/shared/widgets/google_maps_navigation_button.dart';
import 'package:wap_app/shared/widgets/report_dialog.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int _currentImageIndex = 0;
  GoogleMapController? _mapController;
  bool _isLoadingFullData = false;
  Event? _fullEvent;
  bool? _promoterIsFollowing;
  StreamSubscription<AppState>? _authSub;
  // GlobalKey para obtener la posición del botón compartir (iOS requiere sharePositionOrigin)
  final _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _calculateDistance();
    _loadFullEventData();
    _loadPromoterFollowState();
    _loadFavoriteState();
    di.sl<RecordEventViewUseCase>().call(widget.event.id);
    di.sl<AnalyticsService>().logViewEvent(
      eventId: widget.event.id,
      eventName: widget.event.title,
    );

    // En cold start el AppBloc arranca en 'unknown' y el estado de follow/favorite
    // no se puede cargar hasta que se confirme la autenticación.
    // Suscribirse para re-intentar cuando el estado pase a 'authenticated'.
    final appBloc = di.sl<AppBloc>();
    if (appBloc.state.status == AuthStatus.unknown) {
      _authSub = appBloc.stream.listen((state) {
        if (state.status == AuthStatus.authenticated) {
          _authSub?.cancel();
          _authSub = null;
          _loadPromoterFollowState();
          _loadFavoriteState();
        } else if (state.status == AuthStatus.unauthenticated) {
          _authSub?.cancel();
          _authSub = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _calculateDistance() async {
    if (widget.event.distance != null) return; // Ya tiene distancia

    try {
      // Intentar obtener ubicación del HomeBloc
      var userLocation = di.sl<HomeBloc>().state.userLocation;

      // Si no está en el bloc, verificar permiso SIN solicitarlo
      if (userLocation == null) {
        final permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          return; // Sin permiso: no mostrar distancia
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          ),
        );

        userLocation = LatLng(position.latitude, position.longitude);
      }

      // Calcular distancia
      final distance =
          Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            widget.event.latitude,
            widget.event.longitude,
          ) /
          1000;

      // Merge con _fullEvent existente para no perder datos ya cargados
      if (mounted) {
        setState(() {
          _fullEvent = (_fullEvent ?? widget.event).copyWith(
            distance: distance,
          );
        });
      }
    } catch (e) {
      // Error calculando distancia
    }
  }

  Future<void> _loadFullEventData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFullData = true;
    });

    try {
      final getEventById = di.sl<GetEventByIdUseCase>();
      final result = await getEventById(widget.event.slug ?? widget.event.id);

      if (!mounted) return;

      result.fold(
        (failure) {
          // Los errores de conectividad son esperados cuando el usuario no tiene
          // internet. El banner global ya lo informa — usar los datos cacheados
          // de widget.event silenciosamente sin mostrar otro mensaje de error.
          final isConnectivityError =
              (failure is ServerFailure && failure.statusCode == null) ||
              failure is NetworkFailure;
          setState(() {
            _isLoadingFullData = false;
          });
          if (!isConnectivityError && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al cargar datos completos: ${failure.message}',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        (event) async {
          // Calcular distancia para el evento completo si es necesario
          Event eventWithDistance = event;
          if (event.distance == null) {
            try {
              var userLocation = di.sl<HomeBloc>().state.userLocation;

              if (userLocation == null) {
                final permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.always ||
                    permission == LocationPermission.whileInUse) {
                  final position = await Geolocator.getCurrentPosition(
                    locationSettings: const LocationSettings(
                      accuracy: LocationAccuracy.high,
                      distanceFilter: 100,
                    ),
                  );
                  userLocation = LatLng(position.latitude, position.longitude);
                }
              }

              if (userLocation != null) {
                final distance =
                    Geolocator.distanceBetween(
                      userLocation.latitude,
                      userLocation.longitude,
                      event.latitude,
                      event.longitude,
                    ) /
                    1000;

                eventWithDistance = event.copyWith(distance: distance);
              }
            } catch (e) {
              // Error calculando distancia
            }
          }

          if (!mounted) return;

          setState(() {
            // Merge inteligente: el fullEvent toma prioridad, pero se preservan
            // los campos de widget.event Y de _fullEvent previo si el endpoint
            // no los devuelve (evita sobreescribir estado ya cargado, ej. isFavorite)
            _fullEvent = eventWithDistance.copyWith(
              promoterId:
                  eventWithDistance.promoterId ??
                  _fullEvent?.promoterId ??
                  widget.event.promoterId,
              promoterName:
                  eventWithDistance.promoterName ??
                  _fullEvent?.promoterName ??
                  widget.event.promoterName,
              promoterAvatarUrl:
                  eventWithDistance.promoterAvatarUrl ??
                  _fullEvent?.promoterAvatarUrl ??
                  widget.event.promoterAvatarUrl,
              promoterEmail:
                  eventWithDistance.promoterEmail ??
                  _fullEvent?.promoterEmail ??
                  widget.event.promoterEmail,
              status:
                  eventWithDistance.status ??
                  _fullEvent?.status ??
                  widget.event.status,
              isFavorite:
                  eventWithDistance.isFavorite ||
                  (_fullEvent?.isFavorite ?? false) ||
                  widget.event.isFavorite,
            );
            _isLoadingFullData = false;
          });

          // Re-intentar cargar follow si aún no se ha podido
          // (cubre el caso en que promoterId ya estaba disponible pero
          // el auth estaba unknown en initState)
          if (_promoterIsFollowing == null && _fullEvent?.promoterId != null) {
            _loadPromoterFollowState();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFullData = false;
      });
    }
  }

  Future<void> _registerShare() async {
    try {
      await di.sl<Dio>().post('/events/${_displayEvent.id}/share');
    } catch (_) {}
  }

  Future<void> _onShare() async {
    final eventSlug = _displayEvent.slug ?? _displayEvent.id;
    final url = 'https://www.whataplan.net/es/eventos/$eventSlug';
    // iOS necesita sharePositionOrigin para anclar el popover del share sheet.
    // Usamos el RenderBox del botón para obtener su posición y tamaño reales.
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await Share.share(
      '¡Mira que WAP he encontrado! - ${_displayEvent.title}\n$url',
      subject: _displayEvent.title,
      sharePositionOrigin: sharePositionOrigin,
    );
    _registerShare();
    di.sl<AnalyticsService>().logShareEvent(
      eventId: _displayEvent.id,
      eventName: _displayEvent.title,
    );
  }

  Future<void> _loadFavoriteState() async {
    if (!mounted) return;
    // Solo si el evento no está ya marcado como favorito
    if (widget.event.isFavorite) return;
    // Solo si el usuario está autenticado
    if (di.sl<AppBloc>().state.status != AuthStatus.authenticated) return;

    try {
      final dio = di.sl<Dio>();
      final response = await dio.get('/events/favorites');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
        if (data is List) {
          final isFav = data.any(
            (json) => json['id'].toString() == widget.event.id,
          );
          if (isFav) {
            setState(() {
              _fullEvent = (_fullEvent ?? widget.event).copyWith(
                isFavorite: true,
              );
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadPromoterFollowState() async {
    final promoterId = widget.event.promoterId ?? _fullEvent?.promoterId;
    if (promoterId == null || !mounted) return;

    // Solo si el usuario está autenticado
    if (di.sl<AppBloc>().state.status != AuthStatus.authenticated) return;

    try {
      final getProfile = di.sl<GetPromoterProfileUseCase>();
      final result = await getProfile(promoterId);
      if (!mounted) return;
      result.fold(
        (_) {},
        (profile) => setState(() => _promoterIsFollowing = profile.isFollowing),
      );
    } catch (_) {}
  }

  Event get _displayEvent => _fullEvent ?? widget.event;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Navega hacia atrás de forma segura.
  /// Si hay páginas anteriores en el stack se hace pop.
  /// Si esta es la única página (arrancada desde notificación), va a /home.
  void _navigateBack() {
    if (goRouter.canPop()) {
      goRouter.pop();
    } else {
      goRouter.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final imageUrls =
        _displayEvent.imageUrls ??
        (_displayEvent.imageUrl != null ? [_displayEvent.imageUrl!] : []);

    // Mostrar logo animado mientras cargan los datos completos
    if (_isLoadingFullData && _fullEvent == null) {
      return Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: context.colorScheme.surface,
          leading: IconButton(
            onPressed: _navigateBack,
            icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
          ),
        ),
        body: const Center(
          child: GlowingLogo(
            size: 120,
            logoAssetPath: 'assets/images/icon_light.png',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar simple
          SliverAppBar(
            floating: true,
            backgroundColor: context.colorScheme.surface,
            leading: IconButton(
              onPressed: _navigateBack,
              icon: Icon(
                Icons.arrow_back,
                color: context.colorScheme.onSurface,
              ),
              style: IconButton.styleFrom(
                backgroundColor: context.colorScheme.surface.withAlpha(128),
              ),
            ),
            actions: [
              if (di.sl<AppBloc>().state.status == AuthStatus.authenticated)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'report') {
                      final messenger = ScaffoldMessenger.of(context);
                      final sent = await showReportDialog(
                        context,
                        eventId: _displayEvent.id,
                      );
                      if (sent == true && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reporte enviado. Gracias por ayudarnos a mejorar.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined),
                          SizedBox(width: 8),
                          Text('Reportar evento'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel de imágenes
                if (imageUrls.isNotEmpty)
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: imageUrls.length > 1,
                          onPageChanged: (index, reason) {
                            setState(() => _currentImageIndex = index);
                          },
                        ),
                        items: imageUrls.map((url) {
                          return CachedNetworkImage(
                            imageUrl: url,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color:
                                  context.colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                              ),
                              child: Icon(
                                Icons.event,
                                size: 80,
                                color: context.colorScheme.onPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Indicadores de página
                      if (imageUrls.length > 1)
                        Positioned(
                          bottom: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imageUrls.asMap().entries.map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == entry.key
                                      ? context.colorScheme.onSurface
                                      : context.colorScheme.onSurface.withAlpha(
                                          97,
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  )
                else
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.event,
                        size: 80,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner evento finalizado
                      if (_displayEvent.status == 'FINISHED') ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_busy,
                                color: context.colorScheme.onErrorContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.eventFinishedBanner,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Título
                      Text(
                        _displayEvent.title,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ubicación
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _displayEvent.distance != null
                                  ? '${_displayEvent.venueName ?? ''} • ${_displayEvent.distance!.toStringAsFixed(1)} km'
                                  : (_displayEvent.venueName ?? ''),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurface.withAlpha(
                                  179,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Fecha y hora
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatEventDateTime(_displayEvent.startDate),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface.withAlpha(
                                179,
                              ),
                            ),
                          ),
                          if (_displayEvent.endDate != null) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.schedule,
                              size: 20,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatEventDuration(
                                _displayEvent.startDate,
                                _displayEvent.endDate!,
                              ),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurface.withAlpha(
                                  179,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Precio
                      Row(
                        children: [
                          Icon(
                            Icons.euro,
                            size: 20,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _displayEvent.price == null ||
                                    _displayEvent.price == 0
                                ? t.eventCardFree
                                : '${_displayEvent.price!.toStringAsFixed(2)} €',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface.withAlpha(
                                179,
                              ),
                              fontWeight: _displayEvent.price == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Categorías (chips)
                      if (_displayEvent.categories != null &&
                          _displayEvent.categories!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _displayEvent.categories!
                              .map(
                                (category) => _buildCategoryChip(
                                  context,
                                  category.name.toUpperCase(),
                                  isPrimary: true,
                                ),
                              )
                              .toList(),
                        )
                      else if (_displayEvent.categorySlug != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildCategoryChip(
                              context,
                              _displayEvent.categorySlug!.toUpperCase(),
                              isPrimary: true,
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),

                      // Descripción
                      _buildSection(
                        context,
                        icon: Icons.description,
                        title: t.eventDetailDescription,
                        child: Text(
                          _displayEvent.description ??
                              t.eventDetailNoDescription,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(179),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Enlace del origen del evento (source_url)
                      if (_displayEvent.sourceUrl != null &&
                          _displayEvent.sourceUrl!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSection(
                              context,
                              icon: Icons.link,
                              title: t.eventDetailSource,
                              child: GestureDetector(
                                onTap: () =>
                                    _launchUrl(_displayEvent.sourceUrl!),
                                child: Text(
                                  _displayEvent.sourceUrl!,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),

                      // Ubicación con mapa de Google Maps
                      _buildSection(
                        context,
                        icon: Icons.location_on,
                        title: t.eventDetailLocation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[900],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Mapa de Google Maps
                                    GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          _displayEvent.latitude,
                                          _displayEvent.longitude,
                                        ),
                                        zoom: 15,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId(
                                            'event_location',
                                          ),
                                          position: LatLng(
                                            _displayEvent.latitude,
                                            _displayEvent.longitude,
                                          ),
                                        ),
                                      },
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: false,
                                      mapToolbarEnabled: false,
                                      zoomGesturesEnabled: false,
                                      scrollGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      onMapCreated: (controller) {
                                        _mapController = controller;
                                      },
                                    ),
                                    // Overlay con botón
                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: SizedBox(
                                        width: 150,
                                        child: GoogleMapsNavigationButton(
                                          googlePlaceId:
                                              _displayEvent.venueGooglePlaceId,
                                          latitude: _displayEvent.latitude,
                                          longitude: _displayEvent.longitude,
                                          venueName: _displayEvent.venueName,
                                          buttonText: t.eventDetailOpenMap,
                                          buttonType: ButtonType.outlined,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_displayEvent.venueName != null &&
                                _displayEvent.venueName!.isNotEmpty) ...[
                              Text(
                                _displayEvent.venueName!,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              _displayEvent.venueAddress ??
                                  t.eventDetailNoAddress,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurface.withAlpha(
                                  179,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Organizador
                      _buildSection(
                        context,
                        icon: Icons.person,
                        title: t.eventDetailOrganizer,
                        child: Column(
                          children: [
                            // Avatar centrado
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: context.colorScheme.primary,
                              backgroundImage:
                                  _displayEvent.promoterAvatarUrl != null
                                  ? CachedNetworkImageProvider(
                                      _displayEvent.promoterAvatarUrl!,
                                    )
                                  : null,
                              child: _displayEvent.promoterAvatarUrl == null
                                  ? Icon(
                                      Icons.business,
                                      size: 32,
                                      color: context.colorScheme.onPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            // Nombre centrado
                            Text(
                              _displayEvent.promoterName ??
                                  t.eventDetailDefaultOrganizer,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            // Botones
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: t.eventDetailViewProfile,
                                    type: ButtonType.outlined,
                                    icon: Icons.person_outline,
                                    onPressed: () {
                                      final promoterId =
                                          _displayEvent.promoterId;
                                      if (promoterId != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => PromoterProfilePage(
                                              promoterId: promoterId,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (_displayEvent.promoterId != null)
                                  Expanded(
                                    child: FollowButton(
                                      key: ValueKey(
                                        'follow_$_promoterIsFollowing',
                                      ),
                                      promoterId: _displayEvent.promoterId!,
                                      initialIsFollowing:
                                          _promoterIsFollowing ?? false,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ), // Espacio para los botones flotantes
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Botones de acción flotantes
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: context.colorScheme.onSurface.withAlpha(31),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                key: _shareButtonKey,
                onPressed: _onShare,
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Compartir',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FavoriteButton(
                  eventId: _displayEvent.id,
                  initialIsFavorite: _displayEvent.isFavorite,
                  eventName: _displayEvent.title,
                  showLabel: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: context.colorScheme.onPrimary),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label, {
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isPrimary ? AppColors.primaryGradient : null,
        color: isPrimary ? null : context.colorScheme.surface.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurface,
          fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _formatEventDateTime(DateTime date) {
    return DateFormat('EEE, dd MMM • HH:mm', 'es').format(date);
  }

  String _formatEventDuration(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    // Evento multi-día: mostrar fecha fin en el mismo formato que la fecha inicio
    if (endDay != startDay) {
      return _formatEventDateTime(end);
    }

    // Evento de un día: mostrar duración en horas/minutos
    final duration = end.difference(start);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes == 0) {
        return '$hours h';
      }
      return '$hours h $minutes min';
    }
  }
}
