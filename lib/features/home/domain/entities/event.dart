// lib/features/events/domain/entities/event.dart

import 'package:equatable/equatable.dart';

class CategoryInfo extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? svg;
  final String? color;

  const CategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.svg,
    this.color,
  });

  @override
  List<Object?> get props => [id, name, slug, svg, color];
}

class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? slug;
  final DateTime startDate;
  final DateTime? endDate;
  final double latitude;
  final double longitude;
  final String? imageUrl; // Imagen principal (para compatibilidad)
  final List<String>? imageUrls; // Lista de todas las imágenes
  final String? categoryId; // Categoría principal (para compatibilidad)
  final String? categorySlug; // Categoría principal (para compatibilidad)
  final String? categorySvg; // Categoría principal (para compatibilidad)
  final List<CategoryInfo>? categories; // Lista completa de categorías
  final double? distance;
  final double? price;
  final String? venueName;
  final String? venueAddress;
  final String? venueGooglePlaceId;
  final String? promoterId;
  final String? promoterName;
  final String? promoterAvatarUrl;
  final String? promoterEmail;
  final bool isFavorite; // Si está en favoritos del usuario autenticado
  final String? status; // PUBLISHED | FINISHED
  final String? sourceUrl; // URL del origen del evento

  const Event({
    required this.id,
    required this.title,
    this.description,
    this.slug,
    required this.startDate,
    this.endDate,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.imageUrls,
    this.categoryId,
    this.categorySlug,
    this.categorySvg,
    this.categories,
    this.distance,
    this.price,
    this.venueName,
    this.venueAddress,
    this.venueGooglePlaceId,
    this.promoterId,
    this.promoterName,
    this.promoterAvatarUrl,
    this.promoterEmail,
    this.isFavorite = false, // Por defecto false
    this.status,
    this.sourceUrl,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    slug,
    startDate,
    endDate,
    latitude,
    longitude,
    imageUrl,
    imageUrls,
    categoryId,
    categorySlug,
    categorySvg,
    categories,
    distance,
    price,
    venueName,
    venueAddress,
    promoterName,
    promoterAvatarUrl,
    promoterEmail,
    isFavorite,
    status,
    sourceUrl,
  ];

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? slug,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? imageUrls,
    String? categoryId,
    String? categorySlug,
    String? categorySvg,
    List<CategoryInfo>? categories,
    double? distance,
    double? price,
    String? venueName,
    String? venueAddress,
    String? venueGooglePlaceId,
    String? promoterId,
    String? promoterName,
    String? promoterAvatarUrl,
    String? promoterEmail,
    bool? isFavorite,
    String? status,
    String? sourceUrl,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      categorySlug: categorySlug ?? this.categorySlug,
      categorySvg: categorySvg ?? this.categorySvg,
      categories: categories ?? this.categories,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      venueGooglePlaceId: venueGooglePlaceId ?? this.venueGooglePlaceId,
      promoterId: promoterId ?? this.promoterId,
      promoterName: promoterName ?? this.promoterName,
      promoterAvatarUrl: promoterAvatarUrl ?? this.promoterAvatarUrl,
      promoterEmail: promoterEmail ?? this.promoterEmail,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}
