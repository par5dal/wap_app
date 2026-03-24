// lib/features/home/domain/entities/paginated_events_response.dart

import 'package:equatable/equatable.dart';
import 'package:wap_app/features/home/domain/entities/public_event.dart';

class PaginatedEventsResponse extends Equatable {
  final List<PublicEvent> events;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedEventsResponse({
    required this.events,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [events, total, page, limit, totalPages];
}
