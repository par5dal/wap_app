// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventImageModel _$EventImageModelFromJson(Map<String, dynamic> json) =>
    _EventImageModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String?,
      url: json['url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
    );

Map<String, dynamic> _$EventImageModelToJson(_EventImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'url': instance.url,
      'is_primary': instance.isPrimary,
    };
