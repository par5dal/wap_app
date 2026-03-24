// lib/features/home/domain/entities/map_point.dart

import 'package:equatable/equatable.dart';
import 'package:wap_app/features/home/data/models/category_model.dart';

class MapPoint extends Equatable {
  final String id;
  final String title;
  final String slug; // Para URL: /eventos/{slug}
  final double latitude;
  final double longitude;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final double price;
  final String currency; // "EUR", "USD"
  final String venueName;
  final String? googlePlaceId;

  // Categoría principal (para el icono del marker)
  final String primaryCategoryId;
  final String primaryCategoryName;
  final String primaryCategorySlug;
  final String? primaryCategoryIcon; // SVG del icono

  // Categorías secundarias
  final List<CategoryModel> secondaryCategories;

  final String? primaryImageUrl;
  final String? promoterId;

  const MapPoint({
    required this.id,
    required this.title,
    required this.slug,
    required this.latitude,
    required this.longitude,
    required this.startDatetime,
    required this.endDatetime,
    required this.price,
    required this.currency,
    required this.venueName,
    this.googlePlaceId,
    required this.primaryCategoryId,
    required this.primaryCategoryName,
    required this.primaryCategorySlug,
    this.primaryCategoryIcon,
    required this.secondaryCategories,
    this.primaryImageUrl,
    this.promoterId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    latitude,
    longitude,
    startDatetime,
    endDatetime,
    price,
    currency,
    venueName,
    googlePlaceId,
    primaryCategoryId,
    primaryCategoryName,
    primaryCategorySlug,
    primaryCategoryIcon,
    secondaryCategories,
    primaryImageUrl,
    promoterId,
  ];
}
