// lib/features/home/data/models/public_event_model.dart

import 'package:wap_app/features/home/data/models/category_model.dart';
import 'package:wap_app/features/home/data/models/venue_model.dart';
import 'package:wap_app/features/home/domain/entities/public_event.dart';

class PublicEventModel extends PublicEvent {
  const PublicEventModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    required super.startDatetime,
    required super.endDatetime,
    required super.price,
    required super.currency,
    required super.status,
    required super.venue,
    required super.categories,
    required super.imageUrls,
    required super.isFavorite,
    required super.favoritesCount,
    required super.viewsCount,
  });

  factory PublicEventModel.fromJson(Map<String, dynamic> json) {
    return PublicEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      startDatetime: DateTime.parse(
        json['startDatetime'] as String? ?? json['start_datetime'] as String,
      ),
      endDatetime: DateTime.parse(
        json['endDatetime'] as String? ?? json['end_datetime'] as String,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EUR',
      status: json['status'] as String? ?? 'published',
      venue: VenueModel.fromJson(json['venue'] as Map<String, dynamic>),
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isFavorite:
          json['isFavorite'] as bool? ?? json['is_favorite'] as bool? ?? false,
      favoritesCount:
          json['favoritesCount'] as int? ??
          json['favorites_count'] as int? ??
          0,
      viewsCount:
          json['viewsCount'] as int? ?? json['views_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'startDatetime': startDatetime.toIso8601String(),
      'endDatetime': endDatetime.toIso8601String(),
      'price': price,
      'currency': currency,
      'status': status,
      'venue': (venue).toJson(),
      'categories': categories.map((e) => (e).toJson()).toList(),
      'imageUrls': imageUrls,
      'isFavorite': isFavorite,
      'favoritesCount': favoritesCount,
      'viewsCount': viewsCount,
    };
  }
}
