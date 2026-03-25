// lib/features/events/data/models/event_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wap_app/features/home/data/models/category_model.dart';
import 'package:wap_app/features/home/data/models/event_image_model.dart';
import 'package:wap_app/features/home/data/models/venue_model.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/profile/data/models/user_with_profile_model.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@Freezed(fromJson: true, toJson: true)
sealed class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String title,
    String? description,
    String? slug,
    required DateTime startDatetime,
    DateTime? endDatetime,
    String? price,
    String? currency,
    String? status,
    String? moderationStatus,
    String? moderationComment,
    DateTime? moderatedAt,
    required VenueModel venue,
    CategoryModel? category,
    List<CategoryModel>? categories, // Lista completa de categorías
    List<EventImageModel>? images,
    UserWithProfileModel? promoter,
    String?
    promoterDirectId, // promoter_id del tile (cuando no viene objeto promoter completo)
    @Default(false) bool isFavorite, // Si está en favoritos del usuario
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Detectar si es el formato simplificado del endpoint de clustering
    final isClusteringFormat =
        json.containsKey('latitude') &&
        json.containsKey('longitude') &&
        !json.containsKey('venue');

    if (isClusteringFormat) {
      // Formato simplificado de /events/clustering/map-points
      return EventModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        slug: json['slug'] as String?,
        startDatetime: DateTime.parse(json['start_datetime'] as String),
        moderationComment: null,
        moderatedAt: null,
        venue: VenueModel(
          id: '',
          name: json['venue_name'] as String? ?? '',
          address: json['venue_name'] as String? ?? '',
          location: LocationModel(
            type: 'Point',
            coordinates: [
              json['longitude'] as double,
              json['latitude'] as double,
            ],
          ),
        ),
        category: CategoryModel(
          id: json['primary_category_id'] as String? ?? '',
          name: json['primary_category_name'] as String? ?? '',
          slug: json['primary_category_slug'] as String? ?? '',
          svg: json['primary_category_icon'] as String?,
        ),
        images: json['primary_image_url'] != null
            ? [
                EventImageModel(
                  id: '',
                  url: json['primary_image_url'] as String,
                  isPrimary: true,
                ),
              ]
            : null,
        promoter: null,
        promoterDirectId: json['promoter_id'] as String?,
        isFavorite: json['is_favorite'] as bool? ?? false,
        createdAt: null,
        updatedAt: null,
        deletedAt: null,
      );
    }

    // Formato completo del endpoint original
    // El backend ahora envía "categories" como array
    CategoryModel? parsedCategory;
    List<CategoryModel>? parsedCategories;

    if (json['categories'] != null && json['categories'] is List) {
      final categoriesList = json['categories'] as List;
      if (categoriesList.isNotEmpty) {
        parsedCategories = categoriesList
            .map((cat) => CategoryModel.fromJson(cat as Map<String, dynamic>))
            .toList();
        // La primera categoría es la principal
        parsedCategory = parsedCategories.first;
      }
    } else if (json['category'] != null) {
      // Fallback por si aún envía "category" singular
      parsedCategory = CategoryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      );
      parsedCategories = [parsedCategory];
    }

    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String?,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime: json['end_datetime'] != null
          ? DateTime.parse(json['end_datetime'] as String)
          : null,
      price: json['price'] as String?,
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      moderationStatus: json['moderation_status'] as String?,
      moderationComment: json['moderation_comment'] as String?,
      moderatedAt: json['moderated_at'] != null
          ? DateTime.parse(json['moderated_at'] as String)
          : null,
      venue: VenueModel.fromJson(json['venue'] as Map<String, dynamic>),
      category: parsedCategory,
      categories: parsedCategories,
      images: json['images'] != null
          ? (json['images'] as List)
                .map(
                  (img) =>
                      EventImageModel.fromJson(img as Map<String, dynamic>),
                )
                .toList()
          : null,
      promoter: json['promoter'] != null
          ? UserWithProfileModel.fromJson(
              json['promoter'] as Map<String, dynamic>,
            )
          : null,
      promoterDirectId: json['promoter_id'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'slug': slug,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime?.toIso8601String(),
      'price': price,
      'currency': currency,
      'status': status,
      'moderation_status': moderationStatus,
      'moderation_comment': moderationComment,
      'moderated_at': moderatedAt?.toIso8601String(),
      'venue': venue.toJson(),
      'category': category?.toJson(),
      'images': images?.map((img) => img.toJson()).toList(),
      'promoter': promoter?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      startDatetime: event.startDate,
      endDatetime: event.endDate,
      price: event.price?.toStringAsFixed(2),
      currency: 'EUR',
      venue: VenueModel(
        id: '',
        name: event.venueName ?? '',
        address: event.venueAddress ?? '',
        location: LocationModel(
          type: 'Point',
          coordinates: [event.longitude, event.latitude],
        ),
      ),
      category: CategoryModel(id: event.categoryId ?? '', name: '', slug: ''),
    );
  }
}

extension EventModelX on EventModel {
  Event toEntity({double? calculatedDistance}) {
    // Extraer la imagen principal del array de imágenes
    String? primaryImageUrl;
    List<String>? allImageUrls;

    if (images != null && images!.isNotEmpty) {
      // Buscar la imagen marcada como principal
      final primaryImage = images!.firstWhere(
        (img) => img.isPrimary,
        orElse: () => images!.first,
      );
      primaryImageUrl = primaryImage.url;

      // Ordenar imágenes: principal primero, luego el resto
      final sortedImages = [...images!];
      sortedImages.sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;
        return 0;
      });
      allImageUrls = sortedImages.map((img) => img.url).toList();
    }

    // Extraer información del promotor
    String? promoterId;
    String? promoterName;
    String? promoterAvatarUrl;
    String? promoterEmail;

    if (promoter != null) {
      promoterId = promoter!.id;
      final profile = promoter!.profile;
      if (profile != null) {
        // Usar displayName si existe, sino firstName + lastName
        if (profile.displayName != null && profile.displayName!.isNotEmpty) {
          promoterName = profile.displayName;
        } else {
          final firstName = profile.firstName ?? '';
          final lastName = profile.lastName ?? '';
          promoterName = '$firstName $lastName'.trim();
          if (promoterName.isEmpty) {
            promoterName = 'Organizador del Evento'; // Fallback genérico
          }
        }
        promoterAvatarUrl = profile.avatarUrl;
      }
      promoterEmail = promoter!.email;
    } else if (promoterDirectId != null) {
      promoterId = promoterDirectId;
    }

    return Event(
      id: id,
      title: title,
      description: description,
      slug: slug,
      startDate: startDatetime,
      endDate: endDatetime,
      latitude: venue.location.latitude,
      longitude: venue.location.longitude,
      imageUrl: primaryImageUrl,
      imageUrls: allImageUrls,
      categoryId: category?.id,
      categorySlug: category?.slug,
      categorySvg: category?.svg,
      categories: categories
          ?.map(
            (cat) => CategoryInfo(
              id: cat.id,
              name: cat.name,
              slug: cat.slug,
              svg: cat.svg,
              color: cat.color,
            ),
          )
          .toList(),
      distance: calculatedDistance,
      price: price != null ? double.tryParse(price!) : null,
      venueName: venue.name,
      venueAddress: venue.address,
      venueGooglePlaceId: venue.googlePlaceId,
      promoterId: promoterId,
      promoterName: promoterName,
      promoterAvatarUrl: promoterAvatarUrl,
      promoterEmail: promoterEmail,
      isFavorite: isFavorite,
      status: status,
    );
  }
}
