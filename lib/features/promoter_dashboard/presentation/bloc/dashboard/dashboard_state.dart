// lib/features/promoter_dashboard/presentation/bloc/dashboard/dashboard_state.dart

part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<MyEventEntity> events;
  final MyEventsStatsEntity? stats;
  final String? errorMessage;
  final String searchQuery;
  final int selectedTab; // 0 = Active, 1 = Finished

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.events = const [],
    this.stats,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedTab = 0,
  });

  List<MyEventEntity> get filteredEvents {
    final isFinishedTab = selectedTab == 1;
    return events.where((e) {
      final matchesTab = isFinishedTab ? e.isFinished : !e.isFinished;
      return matchesTab;
    }).toList();
  }

  DashboardState copyWith({
    DashboardStatus? status,
    List<MyEventEntity>? events,
    MyEventsStatsEntity? stats,
    String? errorMessage,
    String? searchQuery,
    int? selectedTab,
  }) {
    return DashboardState(
      status: status ?? this.status,
      events: events ?? this.events,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [
    status,
    events,
    stats,
    errorMessage,
    searchQuery,
    selectedTab,
  ];
}
