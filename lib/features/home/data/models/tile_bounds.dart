import 'package:equatable/equatable.dart';

/// Representa los límites geográficos de un tile
class TileBounds extends Equatable {
  final double north;
  final double south;
  final double east;
  final double west;

  const TileBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  /// Convierte a Map para serialización
  Map<String, dynamic> toMap() {
    return {'north': north, 'south': south, 'east': east, 'west': west};
  }

  /// Crea desde Map
  factory TileBounds.fromMap(Map<String, dynamic> map) {
    return TileBounds(
      north: (map['north'] as num).toDouble(),
      south: (map['south'] as num).toDouble(),
      east: (map['east'] as num).toDouble(),
      west: (map['west'] as num).toDouble(),
    );
  }

  /// Crea desde JSON del backend
  factory TileBounds.fromJson(Map<String, dynamic> json) {
    return TileBounds(
      north: (json['north'] as num).toDouble(),
      south: (json['south'] as num).toDouble(),
      east: (json['east'] as num).toDouble(),
      west: (json['west'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [north, south, east, west];

  @override
  String toString() =>
      'TileBounds(north: $north, south: $south, east: $east, west: $west)';
}
