// lib/features/home/data/models/event_image_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_image_model.freezed.dart';
part 'event_image_model.g.dart';

@freezed
sealed class EventImageModel with _$EventImageModel {
  const factory EventImageModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'event_id') String? eventId,
    required String url,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
  }) = _EventImageModel;

  factory EventImageModel.fromJson(Map<String, dynamic> json) =>
      _$EventImageModelFromJson(json);
}
