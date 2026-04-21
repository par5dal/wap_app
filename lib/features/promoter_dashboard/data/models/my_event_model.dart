// lib/features/promoter_dashboard/data/models/my_event_model.dart

import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';

class MyEventModel {
  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String status;
  final String? moderationStatus;
  final String? moderationComment;
  final DateTime startDatetime;
  final DateTime? endDatetime;
  final dynamic price;
  final String? currency;
  final Map<String, dynamic>? venue;
  final List<Map<String, dynamic>>? categories;
  final List<Map<String, dynamic>>? images;
  final int? viewsCount;
  final int? sharesCount;
  final int? favoritesCount;
  final DateTime? createdAt;

  MyEventModel({
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
    this.venue,
    this.categories,
    this.images,
    this.viewsCount,
    this.sharesCount,
    this.favoritesCount,
    this.createdAt,
  });

  factory MyEventModel.fromJson(Map<String, dynamic> json) {
    final venueJson = json['venue'] as Map<String, dynamic>?;

    final cats = (json['categories'] as List?)
        ?.map((c) => c as Map<String, dynamic>)
        .toList();
    final imgs = (json['images'] as List?)
        ?.map((i) => i as Map<String, dynamic>)
        .toList();

    return MyEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      moderationStatus: json['moderation_status'] as String?,
      moderationComment: json['moderation_comment'] as String?,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime: json['end_datetime'] != null
          ? DateTime.parse(json['end_datetime'] as String)
          : null,
      price: json['price'],
      currency: json['currency'] as String?,
      venue: venueJson,
      categories: cats,
      images: imgs,
      viewsCount: json['views_count'] as int?,
      sharesCount: json['shares_count'] as int?,
      favoritesCount: json['favorites_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  MyEventEntity toEntity() {
    final venueJson = venue;
    String? venueName;
    String? venueAddress;
    double? lat;
    double? lng;
    if (venueJson != null) {
      venueName = venueJson['name'] as String?;
      venueAddress = venueJson['address'] as String?;
      final loc = venueJson['location'] as Map<String, dynamic>?;
      final coordsList = loc?['coordinates'] as List?;
      if (coordsList != null && coordsList.length >= 2) {
        lng = (coordsList[0] as num).toDouble();
        lat = (coordsList[1] as num).toDouble();
      }
    }

    final catIds =
        categories?.map((c) => c['id'] as String? ?? '').toList() ?? [];
    final catNames =
        categories?.map((c) => c['name'] as String? ?? '').toList() ?? [];

    // All images: primary first, then the rest
    String? primaryImageUrl;
    final List<String> imageUrls = [];
    if (images != null && images!.isNotEmpty) {
      final primaryFirst = [
        ...images!.where((i) => i['is_primary'] == true),
        ...images!.where((i) => i['is_primary'] != true),
      ];
      for (final img in primaryFirst) {
        final url = img['url'] as String?;
        if (url != null && url.isNotEmpty) imageUrls.add(url);
      }
      primaryImageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    }

    return MyEventEntity(
      id: id,
      title: title,
      slug: slug,
      description: description,
      status: status,
      moderationStatus: moderationStatus,
      moderationComment: moderationComment,
      startDatetime: startDatetime,
      endDatetime: endDatetime,
      price: price != null ? double.tryParse(price.toString()) : null,
      currency: currency,
      venueName: venueName,
      venueAddress: venueAddress,
      venueLatitude: lat,
      venueLongitude: lng,
      categoryIds: catIds,
      categoryNames: catNames,
      primaryImageUrl: primaryImageUrl,
      imageUrls: imageUrls,
      viewsCount: viewsCount,
      sharesCount: sharesCount,
      favoritesCount: favoritesCount,
      createdAt: createdAt,
    );
  }
}
