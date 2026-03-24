// lib/features/home/presentation/widgets/event_list_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/event_detail/presentation/pages/event_detail_page.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/l10n/app_localizations.dart';

class EventListCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventListCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.lightPrimary.withAlpha(51), width: 1),
      ),
      child: InkWell(
        onTap:
            onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventDetailPage(event: event),
                ),
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen del evento
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl ?? '',
                  width: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    color: context.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Contenido
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        event.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Fecha
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatEventDate(event.startDate, t),
                              style: context.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Ubicación
                      if (event.venueName != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.venueName!,
                                style: context.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),

                      // Distancia y Precio
                      Row(
                        children: [
                          // Distancia
                          if (event.distance != null) ...[
                            Icon(
                              Icons.directions_walk,
                              size: 14,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                t.eventCardDistance(
                                  event.distance!.toStringAsFixed(1),
                                ),
                                style: context.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Precio
                          if (event.price != null)
                            Flexible(
                              child: Text(
                                event.price == 0
                                    ? t.eventCardFree
                                    : event.price! % 1 == 0
                                    ? '${event.price!.toInt()} €'
                                    : '${event.price!.toStringAsFixed(2)} €',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: event.price == 0
                                      ? FontWeight.bold
                                      : null,
                                  color: event.price == 0 ? Colors.green : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Icono de flecha
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.chevron_right,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatEventDate(DateTime date, AppLocalizations t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return t.eventCardTodayAt(DateFormat('HH:mm').format(date));
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}
