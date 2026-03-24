// lib/features/events/data/models/venue_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue_model.freezed.dart';
part 'venue_model.g.dart';

@Freezed(fromJson: true, toJson: true)
sealed class VenueModel with _$VenueModel {
  const factory VenueModel({
    required String id,
    required String name,
    required String address,
    String? googlePlaceId,
    required LocationModel location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _VenueModel;

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      googlePlaceId: json['google_place_id'] as String?,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'google_place_id': googlePlaceId,
      'location': location.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

@Freezed(fromJson: true, toJson: true)
sealed class LocationModel with _$LocationModel {
  const LocationModel._(); // Requerido por freezed v3 para computed getters

  const factory LocationModel({
    required String type,
    required List<double> coordinates,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
}
