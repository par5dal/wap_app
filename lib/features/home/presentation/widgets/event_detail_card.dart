// lib/features/events/presentation/widgets/event_detail_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/event_detail/presentation/pages/event_detail_page.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/shared/widgets/custom_button.dart';
import 'package:wap_app/shared/widgets/google_maps_navigation_button.dart';

class EventDetailCard extends StatelessWidget {
  final Event event;
  final VoidCallback onClose;
  final int? colocatedCount; // Número total de eventos colocalizados
  final int? colocatedIndex; // Índice actual (base 0)
  final VoidCallback? onPrevious; // Callback para evento anterior
  final VoidCallback? onNext; // Callback para siguiente evento

  const EventDetailCard({
    super.key,
    required this.event,
    required this.onClose,
    this.colocatedCount,
    this.colocatedIndex,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.lightPrimary.withAlpha(76),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del evento con botón de cerrar
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: context.colorScheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.event,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Botón de cerrar
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
                // Badge de eventos colocalizados
                if (colocatedCount != null && colocatedCount! > 1)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFF02193)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${(colocatedIndex ?? 0) + 1} de $colocatedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                // Botones de navegación entre eventos colocalizados
                if (colocatedCount != null && colocatedCount! > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Botón anterior
                        IconButton(
                          onPressed: onPrevious,
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 32,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Botón siguiente
                        IconButton(
                          onPressed: onNext,
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 32,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Contenido del evento
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del evento
                  Text(
                    event.title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Ubicación: nombre y dirección del venue
                  if (event.venueName != null ||
                      event.venueAddress != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.place,
                          size: 14,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // Si la dirección ya incluye el nombre, mostrar solo la dirección
                              final name = event.venueName;
                              final address = event.venueAddress;
                              final addressContainsName =
                                  name != null &&
                                  address != null &&
                                  address.toLowerCase().startsWith(
                                    name.toLowerCase(),
                                  );

                              if (addressContainsName) {
                                return Text(
                                  address,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withAlpha(153),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }

                              return Text.rich(
                                TextSpan(
                                  children: [
                                    if (name != null)
                                      TextSpan(
                                        text: name,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  context.colorScheme.onSurface,
                                            ),
                                      ),
                                    if (name != null && address != null)
                                      const TextSpan(text: ' · '),
                                    if (address != null)
                                      TextSpan(
                                        text: address,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(153),
                                            ),
                                      ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Información del evento (fecha, distancia, precio)
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      // Fecha
                      Builder(
                        builder: (context) {
                          final ongoing = _isOngoing(
                            event.startDate,
                            event.endDate,
                          );
                          final dateColor = ongoing
                              ? Colors.green.shade600
                              : context.colorScheme.primary;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                ongoing
                                    ? Icons.play_circle_outline
                                    : Icons.schedule,
                                size: 16,
                                color: dateColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatEventDateRange(
                                  event.startDate,
                                  event.endDate,
                                  t,
                                ),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: ongoing ? Colors.green.shade600 : null,
                                  fontWeight: ongoing ? FontWeight.w600 : null,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      // Distancia
                      if (event.distance != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.eventCardDistance(
                                event.distance!.toStringAsFixed(1),
                              ),
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      // Precio
                      if (event.price != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.euro,
                              size: 16,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.price == 0
                                  ? t.eventCardFree
                                  : '${event.price!.toStringAsFixed(2)} €',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: event.price == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botones de acción - Detalles principal, Ir secundario
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomButton(
                          text: t.eventCardDetails,
                          icon: Icons.info_outline,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailPage(event: event),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GoogleMapsNavigationButton(
                          googlePlaceId: event.venueGooglePlaceId,
                          latitude: event.latitude,
                          longitude: event.longitude,
                          venueName: event.venueName,
                          buttonText: t.eventCardGo,
                          buttonType: ButtonType.outlined,
                          icon: Icons.directions,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOngoing(DateTime startDate, DateTime? endDate) {
    final now = DateTime.now();
    return endDate != null && startDate.isBefore(now) && endDate.isAfter(now);
  }

  String _formatEventDateRange(
    DateTime startDate,
    DateTime? endDate,
    AppLocalizations t,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);

    // Caso 1: Evento en curso
    if (endDate != null && startDate.isBefore(now) && endDate.isAfter(now)) {
      final endDay = DateTime(endDate.year, endDate.month, endDate.day);
      final endFormatted = endDay == today
          ? DateFormat('HH:mm').format(endDate)
          : DateFormat('d MMM', t.localeName).format(endDate);
      return t.eventCardOngoing(endFormatted);
    }

    // Caso 2: Evento multi-día futuro
    if (endDate != null) {
      final endDay = DateTime(endDate.year, endDate.month, endDate.day);
      if (endDay != startDay) {
        final startFormatted = startDay == today
            ? t.filterDateToday
            : startDay == tomorrow
            ? t.filterDateTomorrow
            : DateFormat('d MMM', t.localeName).format(startDate);
        final endFormatted = DateFormat('d MMM', t.localeName).format(endDate);
        return '$startFormatted – $endFormatted';
      }
    }

    // Caso 3: Evento de un solo día
    if (startDay == today) {
      return t.eventCardTodayAt(DateFormat('HH:mm').format(startDate));
    } else if (startDay == tomorrow) {
      return t.eventCardTomorrowAt(DateFormat('HH:mm').format(startDate));
    } else {
      return DateFormat('d MMM · HH:mm', t.localeName).format(startDate);
    }
  }
}
