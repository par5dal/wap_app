// lib/features/home/data/models/paginated_events_response_model.dart

import 'package:wap_app/features/home/data/models/public_event_model.dart';
import 'package:wap_app/features/home/domain/entities/paginated_events_response.dart';

class PaginatedEventsResponseModel extends PaginatedEventsResponse {
  const PaginatedEventsResponseModel({
    required super.events,
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory PaginatedEventsResponseModel.fromJson(Map<String, dynamic> json) {
    return PaginatedEventsResponseModel(
      events:
          (json['events'] as List<dynamic>? ?? json['data'] as List<dynamic>?)
              ?.map((e) => PublicEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages:
          json['totalPages'] as int? ?? json['total_pages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => (e as PublicEventModel).toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}
