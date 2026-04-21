// lib/features/promoter_dashboard/presentation/bloc/dashboard/dashboard_event.dart

part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

class DashboardSearchChanged extends DashboardEvent {
  final String query;
  const DashboardSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class DashboardTabChanged extends DashboardEvent {
  final int tabIndex; // 0 = Active, 1 = Finished
  const DashboardTabChanged(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}

class DashboardDeleteEventRequested extends DashboardEvent {
  final String eventId;
  const DashboardDeleteEventRequested(this.eventId);
  @override
  List<Object?> get props => [eventId];
}
