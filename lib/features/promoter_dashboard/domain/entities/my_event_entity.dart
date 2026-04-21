// lib/features/promoter_dashboard/domain/entities/my_event_entity.dart

import 'package:equatable/equatable.dart';

class MyEventEntity extends Equatable {
  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String status; // DRAFT | PUBLISHED | FINISHED | CANCELLED
  final String? moderationStatus; // PENDING | APPROVED | REJECTED
  final String? moderationComment;
  final DateTime startDatetime;
  final DateTime? endDatetime;
  final double? price;
  final String? currency;
  final String? venueName;
  final String? venueAddress;
  final double? venueLatitude;
  final double? venueLongitude;
  final List<String> categoryIds;
  final List<String> categoryNames;
  final String? primaryImageUrl;
  final List<String> imageUrls;
  final int? viewsCount;
  final int? sharesCount;
  final int? favoritesCount;
  final DateTime? createdAt;

  const MyEventEntity({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    required this.status,
    this.moderationStatus,
    this.moderationComment,
    required this.startDatetime,
    this.endDatetime,
    this.price,
    this.currency,
    this.venueName,
    this.venueAddress,
    this.venueLatitude,
    this.venueLongitude,
    this.categoryIds = const [],
    this.categoryNames = const [],
    this.primaryImageUrl,
    this.imageUrls = const [],
    this.viewsCount,
    this.sharesCount,
    this.favoritesCount,
    this.createdAt,
  });

  bool get isFinished => status == 'FINISHED';
  bool get isPublished => status == 'PUBLISHED';
  bool get isDraft => status == 'DRAFT';
  bool get isCancelled => status == 'CANCELLED';

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    moderationStatus,
    startDatetime,
    sharesCount,
    favoritesCount,
  ];
}
