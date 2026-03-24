// lib/features/home/domain/entities/public_event.dart

import 'package:equatable/equatable.dart';
import 'package:wap_app/features/home/data/models/category_model.dart';
import 'package:wap_app/features/home/data/models/venue_model.dart';

class PublicEvent extends Equatable {
  final String id;
  final String title;
  final String slug;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final double price;
  final String currency; // "EUR", "USD", etc.
  final String status; // 'published', 'draft', 'cancelled'

  final VenueModel venue;
  final List<CategoryModel> categories;
  final List<String> imageUrls;

  final bool isFavorite;
  final int favoritesCount;
  final int viewsCount;

  const PublicEvent({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.price,
    required this.currency,
    required this.status,
    required this.venue,
    required this.categories,
    required this.imageUrls,
    required this.isFavorite,
    required this.favoritesCount,
    required this.viewsCount,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    description,
    startDatetime,
    endDatetime,
    price,
    currency,
    status,
    venue,
    categories,
    imageUrls,
    isFavorite,
    favoritesCount,
    viewsCount,
  ];
}
