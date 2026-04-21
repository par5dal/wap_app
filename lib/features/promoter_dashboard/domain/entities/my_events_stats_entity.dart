// lib/features/promoter_dashboard/domain/entities/my_events_stats_entity.dart

import 'package:equatable/equatable.dart';

class MyEventsStatsEntity extends Equatable {
  final int totalEvents;
  final int activeEvents;
  final int totalViews;
  final int totalFavorites;
  final int totalFollowers;

  const MyEventsStatsEntity({
    required this.totalEvents,
    required this.activeEvents,
    required this.totalViews,
    required this.totalFavorites,
    this.totalFollowers = 0,
  });

  @override
  List<Object?> get props => [
    totalEvents,
    activeEvents,
    totalViews,
    totalFavorites,
    totalFollowers,
  ];
}
