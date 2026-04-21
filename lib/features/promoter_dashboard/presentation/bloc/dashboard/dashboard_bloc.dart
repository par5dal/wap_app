// lib/features/promoter_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wap_app/features/manage_event/domain/repositories/manage_event_repository.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_events_stats_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/usecases/delete_my_event_usecase.dart';
import 'package:wap_app/features/promoter_dashboard/domain/usecases/get_my_events_stats_usecase.dart';
import 'package:wap_app/features/promoter_dashboard/domain/usecases/get_my_events_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetMyEventsUseCase getMyEvents;
  final GetMyEventsStatsUseCase getMyEventsStats;
  final DeleteMyEventUseCase deleteMyEvent;
  final ManageEventRepository manageEventRepository;

  Timer? _searchDebounce;

  DashboardBloc({
    required this.getMyEvents,
    required this.getMyEventsStats,
    required this.deleteMyEvent,
    required this.manageEventRepository,
  }) : super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onRefresh);
    on<DashboardSearchChanged>(_onSearchChanged);
    on<DashboardTabChanged>(_onTabChanged);
    on<DashboardDeleteEventRequested>(_onDeleteEvent);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await _loadAll(emit);
  }

  Future<void> _onRefresh(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadAll(emit);
  }

  Future<void> _loadAll(Emitter<DashboardState> emit) async {
    final eventsResult = await getMyEvents(
      page: 1,
      limit: 100,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );
    final statsResult = await getMyEventsStats();

    eventsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (events) {
        final stats = statsResult.fold((_) => null, (s) => s);
        emit(
          state.copyWith(
            status: DashboardStatus.loaded,
            events: events,
            stats: stats,
            errorMessage: null,
          ),
        );
      },
    );
  }

  void _onSearchChanged(
    DashboardSearchChanged event,
    Emitter<DashboardState> emit,
  ) {
    _searchDebounce?.cancel();
    emit(state.copyWith(searchQuery: event.query));
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      add(const DashboardRefreshRequested());
    });
  }

  void _onTabChanged(DashboardTabChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(selectedTab: event.tabIndex));
  }

  Future<void> _onDeleteEvent(
    DashboardDeleteEventRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Find the event in current list
    final eventToDelete = state.events.firstWhere(
      (e) => e.id == event.eventId,
      orElse: () => MyEventEntity(
        id: '',
        title: '',
        status: '',
        startDatetime: DateTime(2000),
      ),
    );

    if (eventToDelete.id.isEmpty) return;

    // If published, unpublish; otherwise delete
    if (eventToDelete.isPublished) {
      final result = await manageEventRepository.unpublishEvent(event.eventId);
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (_) {
          // Refresh events list to get updated status
          add(const DashboardRefreshRequested());
        },
      );
    } else {
      // Delete draft or other status
      final result = await deleteMyEvent(event.eventId);
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (_) {
          // Refresh events list to get updated state
          add(const DashboardRefreshRequested());
        },
      );
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
