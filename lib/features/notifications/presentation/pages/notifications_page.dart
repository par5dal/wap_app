// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';
import 'package:wap_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wap_app/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<NotificationsBloc>()..add(const LoadNotifications()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<NotificationsBloc>().add(const LoadMoreNotifications());
    }
  }

  Future<void> _onRefresh() async {
    context.read<NotificationsBloc>().add(const LoadNotifications());
    // wait for state to settle
    await context.read<NotificationsBloc>().stream.firstWhere(
      (s) => s is! NotificationsLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notificationsTitle),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is! NotificationsLoaded || state.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return PopupMenuButton<_NotifAction>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) {
                  switch (action) {
                    case _NotifAction.markAllRead:
                      context.read<NotificationsBloc>().add(
                        const MarkAllNotificationsRead(),
                      );
                    case _NotifAction.deleteAll:
                      _confirmDeleteAll(context);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _NotifAction.markAllRead,
                    child: Text(context.l10n.notificationsMarkAllRead),
                  ),
                  PopupMenuItem(
                    value: _NotifAction.deleteAll,
                    child: Text(
                      context.l10n.notificationsDeleteAll,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError && state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<NotificationsBloc>().add(
                      const LoadNotifications(),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final items = state.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.notificationsEmpty,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  items.length + (state is NotificationsLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final notification = items[index];
                final navPath = _navigationPath(notification);
                return NotificationTile(
                  notification: notification,
                  onTap: () => context.read<NotificationsBloc>().add(
                    MarkNotificationRead(notification.id),
                  ),
                  onNavigate: navPath != null
                      ? () => context.push(navPath)
                      : null,
                  onDismiss: () => context.read<NotificationsBloc>().add(
                    DeleteNotification(notification.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Returns the in-app route to push when a notification is actionable,
  /// or null when there is no navigable target.
  String? _navigationPath(UserNotification notification) {
    final data = notification.data;
    if (data == null) return null;
    final type = data['type'] as String?;
    final eventId = data['event_id']?.toString();
    if (type == 'new_event' && eventId != null && eventId.isNotEmpty) {
      return '/events/$eventId';
    }
    return null;
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.notificationsDeleteAll),
        content: Text(context.l10n.notificationsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx, true);
              context.read<NotificationsBloc>().add(
                const DeleteAllNotifications(),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

enum _NotifAction { markAllRead, deleteAll }
