// lib/features/promoter_dashboard/presentation/widgets/my_event_list_item.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';

class MyEventListItem extends StatelessWidget {
  final MyEventEntity event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyEventListItem({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  Future<bool?> _handleConfirmDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    final isPublished = event.isPublished;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isPublished
              ? context.l10n.eventStatusUnpublish
              : context.l10n.dashboardDeleteEventTitle,
        ),
        content: Text(
          isPublished
              ? '¿Estás seguro de que quieres despublicar este evento?'
              : context.l10n.dashboardDeleteEventConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isPublished
                  ? const Color(0xFFF59E0B)
                  : Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isPublished
                  ? context.l10n.eventStatusUnpublish
                  : context.l10n.delete,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Execute the action but always return false so the Dismissible snaps back.
      // The list will be refreshed by the BLoC independently.
      // This avoids the "dismissed Dismissible still in tree" error that happens
      // when the item stays in the list after unpublish (status changes but id stays).
      onDelete();
    }
    return false;
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('d MMM · HH:mm', context.l10n.localeName);
    final isPublished = event.isPublished;

    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (dir) => _handleConfirmDismiss(context, dir),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: isPublished
              ? const Color(0xFFF59E0B) // Orange for unpublish
              : theme.colorScheme.error, // Red for delete
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPublished ? Icons.cloud_off_outlined : Icons.delete_outline,
              color: isPublished ? Colors.black87 : theme.colorScheme.onError,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              isPublished
                  ? context.l10n.eventStatusUnpublish
                  : context.l10n.delete,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isPublished ? Colors.black87 : theme.colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onEdit,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail — fills full card height
                SizedBox(
                  width: 100,
                  child: event.primaryImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: event.primaryImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _ImagePlaceholder(
                            icon: Icons.image_outlined,
                            theme: theme,
                          ),
                          errorWidget: (_, __, ___) => _ImagePlaceholder(
                            icon: Icons.broken_image_outlined,
                            theme: theme,
                          ),
                        )
                      : _ImagePlaceholder(
                          icon: Icons.event_outlined,
                          theme: theme,
                        ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + status badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _StatusBadge(
                              status: event.status,
                              modStatus: event.moderationStatus,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateFmt.format(event.startDatetime.toLocal()),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Venue
                        if (event.venueName != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.venueName!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(),
                        // Stats row
                        Row(
                          children: [
                            if (event.viewsCount != null) ...[
                              Icon(
                                Icons.visibility_outlined,
                                size: 13,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatCount(event.viewsCount!),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (event.favoritesCount != null) ...[
                              Icon(
                                Icons.favorite_outline,
                                size: 13,
                                color: Colors.redAccent.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatCount(event.favoritesCount!),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (event.sharesCount != null) ...[
                              Icon(
                                Icons.share_outlined,
                                size: 13,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatCount(event.sharesCount!),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final ThemeData theme;

  const _ImagePlaceholder({required this.icon, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        icon,
        size: 32,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String? modStatus;

  const _StatusBadge({required this.status, this.modStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    String label;

    switch (status) {
      case 'PUBLISHED':
        color = const Color(0xFF10B981);
        label = context.l10n.eventStatusPublished;
      case 'FINISHED':
        color = Colors.blueGrey;
        label = context.l10n.eventStatusFinished;
      case 'CANCELLED':
        color = theme.colorScheme.error;
        label = context.l10n.eventStatusCancelled;
      case 'PENDING_APPROVAL':
        color = const Color(0xFFF59E0B);
        label = context.l10n.eventStatusPendingApproval;
      default:
        // DRAFT
        if (modStatus == 'REJECTED') {
          color = theme.colorScheme.error;
          label = context.l10n.eventStatusRejected;
        } else {
          color = Colors.blueGrey;
          label = context.l10n.eventStatusDraft;
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 9,
        ),
      ),
    );
  }
}
