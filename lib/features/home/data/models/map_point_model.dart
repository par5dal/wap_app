// lib/features/home/data/models/map_point_model.dart

import 'package:wap_app/features/home/data/models/category_model.dart';
import 'package:wap_app/features/home/domain/entities/map_point.dart';

class MapPointModel extends MapPoint {
  const MapPointModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.latitude,
    required super.longitude,
    required super.startDatetime,
    required super.endDatetime,
    required super.price,
    required super.currency,
    required super.venueName,
    super.googlePlaceId,
    required super.primaryCategoryId,
    required super.primaryCategoryName,
    required super.primaryCategorySlug,
    super.primaryCategoryIcon,
    required super.secondaryCategories,
    super.primaryImageUrl,
    super.promoterId,
  });

  factory MapPointModel.fromJson(Map<String, dynamic> json) {
    return MapPointModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      startDatetime: DateTime.parse(
        json['startDatetime'] as String? ?? json['start_datetime'] as String,
      ),
      endDatetime: DateTime.parse(
        json['endDatetime'] as String? ?? json['end_datetime'] as String,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EUR',
      venueName: json['venueName'] as String? ?? json['venue_name'] as String,
      googlePlaceId:
          json['googlePlaceId'] as String? ??
          json['google_place_id'] as String?,
      primaryCategoryId:
          json['primaryCategoryId'] as String? ??
          json['primary_category_id'] as String,
      primaryCategoryName:
          json['primaryCategoryName'] as String? ??
          json['primary_category_name'] as String,
      primaryCategorySlug:
          json['primaryCategorySlug'] as String? ??
          json['primary_category_slug'] as String,
      primaryCategoryIcon:
          json['primaryCategoryIcon'] as String? ??
          json['primary_category_icon'] as String?,
      secondaryCategories:
          (json['secondaryCategories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['secondary_categories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      primaryImageUrl:
          json['primaryImageUrl'] as String? ??
          json['primary_image_url'] as String?,
      promoterId:
          json['promoterId'] as String? ?? json['promoter_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'latitude': latitude,
      'longitude': longitude,
      'startDatetime': startDatetime.toIso8601String(),
      'endDatetime': endDatetime.toIso8601String(),
      'price': price,
      'currency': currency,
      'venueName': venueName,
      if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
      'primaryCategoryId': primaryCategoryId,
      'primaryCategoryName': primaryCategoryName,
      'primaryCategorySlug': primaryCategorySlug,
      if (primaryCategoryIcon != null)
        'primaryCategoryIcon': primaryCategoryIcon,
      'secondaryCategories': secondaryCategories
          .map((e) => (e).toJson())
          .toList(),
      if (primaryImageUrl != null) 'primaryImageUrl': primaryImageUrl,
      if (promoterId != null) 'promoterId': promoterId,
    };
  }
}
