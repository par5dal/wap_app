// lib/features/promoter_dashboard/presentation/pages/promoter_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_events_stats_entity.dart';
import 'package:wap_app/features/promoter_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wap_app/features/promoter_dashboard/presentation/widgets/my_event_list_item.dart';
import 'package:wap_app/features/promoter_dashboard/presentation/widgets/stat_card_widget.dart';

class PromoterDashboardPage extends StatelessWidget {
  const PromoterDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(const DashboardLoadRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();
  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      context.read<DashboardBloc>().add(
        DashboardTabChanged(_tabController.index),
      );
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dashboardTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.l10n.dashboardCreateEvent,
            onPressed: () => context.push('/manage-event'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.status != DashboardStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DashboardStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(state.errorMessage ?? context.l10n.genericError),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<DashboardBloc>().add(
                        const DashboardRefreshRequested(),
                      ),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final activeEvents = state.events
              .where((e) => !e.isFinished)
              .toList();
          final finishedEvents = state.events
              .where((e) => e.isFinished)
              .toList();

          return Column(
            children: [
              // ── Stats strip ──────────────────────────────────────────
              if (state.stats != null) _StatsStrip(stats: state.stats!),

              // ── Search bar ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.dashboardSearchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<DashboardBloc>().add(
                                const DashboardSearchChanged(''),
                              );
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (val) => context.read<DashboardBloc>().add(
                    DashboardSearchChanged(val),
                  ),
                ),
              ),

              // ── TabBar ───────────────────────────────────────────────
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.dashboardTabActive),
                        if (activeEvents.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _CountBadge(
                            count: activeEvents.length,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.dashboardTabFinished),
                        if (finishedEvents.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _CountBadge(
                            count: finishedEvents.length,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // ── Tab content ──────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _EventsTab(
                      events: activeEvents,
                      onRefresh: () => context.read<DashboardBloc>().add(
                        const DashboardRefreshRequested(),
                      ),
                      onEdit: (e) =>
                          context.push('/manage-event/${e.id}', extra: e),
                      onDelete: (e) => context.read<DashboardBloc>().add(
                        DashboardDeleteEventRequested(e.id),
                      ),
                    ),
                    _EventsTab(
                      events: finishedEvents,
                      onRefresh: () => context.read<DashboardBloc>().add(
                        const DashboardRefreshRequested(),
                      ),
                      onEdit: (e) =>
                          context.push('/manage-event/${e.id}', extra: e),
                      onDelete: (e) => context.read<DashboardBloc>().add(
                        DashboardDeleteEventRequested(e.id),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats strip
// ─────────────────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final MyEventsStatsEntity stats;

  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            StatCardWidget(
              label: context.l10n.dashboardStatsTotalEvents,
              value: '${stats.totalEvents}',
              icon: Icons.event_outlined,
            ),
            const SizedBox(width: 8),
            StatCardWidget(
              label: context.l10n.dashboardStatsActiveEvents,
              value: '${stats.activeEvents}',
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            StatCardWidget(
              label: context.l10n.dashboardStatsTotalViews,
              value: '${stats.totalViews}',
              icon: Icons.visibility_outlined,
              iconColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 8),
            StatCardWidget(
              label: context.l10n.dashboardStatsTotalFavorites,
              value: '${stats.totalFavorites}',
              icon: Icons.favorite_outline,
              iconColor: Colors.redAccent,
            ),
            const SizedBox(width: 8),
            StatCardWidget(
              label: context.l10n.dashboardStatsFollowers,
              value: '${stats.totalFollowers}',
              icon: Icons.people_outline,
              iconColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab content (search + list)
// ─────────────────────────────────────────────────────────────────────────────
class _EventsTab extends StatelessWidget {
  final List<MyEventEntity> events;
  final VoidCallback onRefresh;
  final void Function(MyEventEntity) onEdit;
  final void Function(MyEventEntity) onDelete;

  const _EventsTab({
    required this.events,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 60),
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 52,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.dashboardNoEvents,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, index) {
          final event = events[index];
          return MyEventListItem(
            event: event,
            onEdit: () => onEdit(event),
            onDelete: () => onDelete(event),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Count badge on tab label
// ─────────────────────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
