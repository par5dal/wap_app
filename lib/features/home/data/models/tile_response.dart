import 'package:equatable/equatable.dart';
import 'package:wap_app/features/home/data/models/tile_coords.dart';
import 'package:wap_app/features/home/data/models/tile_bounds.dart';
import 'package:wap_app/features/home/data/models/tile_metadata.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';

/// Respuesta completa del endpoint /events/tiles/:z/:x/:y
class TileResponse extends Equatable {
  final TileCoords tile;
  final TileBounds bounds;
  final TileMetadata metadata;
  final List<EventModel> events;

  const TileResponse({
    required this.tile,
    required this.bounds,
    required this.metadata,
    required this.events,
  });

  /// Crea desde JSON del backend
  factory TileResponse.fromJson(Map<String, dynamic> json) {
    return TileResponse(
      tile: TileCoords.fromMap(json['tile'] as Map<String, dynamic>),
      bounds: TileBounds.fromJson(json['bounds'] as Map<String, dynamic>),
      metadata: TileMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      events: (json['events'] as List<dynamic>)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'tile': tile.toMap(),
      'bounds': bounds.toMap(),
      'metadata': metadata.toJson(),
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [tile, bounds, metadata, events];

  @override
  String toString() =>
      'TileResponse(tile: $tile, bounds: $bounds, metadata: $metadata, eventsCount: ${events.length})';
}
