// lib/features/manage_event/domain/entities/saved_venue_entity.dart

import 'package:equatable/equatable.dart';

class SavedVenueEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;

  const SavedVenueEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [id, name, address, lat, lng];
}
