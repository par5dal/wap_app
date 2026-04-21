// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventModel _$EventModelFromJson(Map<String, dynamic> json) => _EventModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  slug: json['slug'] as String?,
  startDatetime: DateTime.parse(json['startDatetime'] as String),
  endDatetime: json['endDatetime'] == null
      ? null
      : DateTime.parse(json['endDatetime'] as String),
  price: json['price'] as String?,
  currency: json['currency'] as String?,
  status: json['status'] as String?,
  moderationStatus: json['moderationStatus'] as String?,
  moderationComment: json['moderationComment'] as String?,
  moderatedAt: json['moderatedAt'] == null
      ? null
      : DateTime.parse(json['moderatedAt'] as String),
  venue: VenueModel.fromJson(json['venue'] as Map<String, dynamic>),
  category: json['category'] == null
      ? null
      : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => EventImageModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  promoter: json['promoter'] == null
      ? null
      : UserWithProfileModel.fromJson(json['promoter'] as Map<String, dynamic>),
  promoterDirectId: json['promoterDirectId'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  sourceUrl: json['sourceUrl'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$EventModelToJson(_EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'slug': instance.slug,
      'startDatetime': instance.startDatetime.toIso8601String(),
      'endDatetime': instance.endDatetime?.toIso8601String(),
      'price': instance.price,
      'currency': instance.currency,
      'status': instance.status,
      'moderationStatus': instance.moderationStatus,
      'moderationComment': instance.moderationComment,
      'moderatedAt': instance.moderatedAt?.toIso8601String(),
      'venue': instance.venue,
      'category': instance.category,
      'categories': instance.categories,
      'images': instance.images,
      'promoter': instance.promoter,
      'promoterDirectId': instance.promoterDirectId,
      'isFavorite': instance.isFavorite,
      'sourceUrl': instance.sourceUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
