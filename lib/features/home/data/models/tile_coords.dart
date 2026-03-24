import 'package:equatable/equatable.dart';

/// Representa las coordenadas de un tile en el sistema Slippy Map Tiles
/// Compatible con OpenStreetMap, Google Maps, Mapbox
class TileCoords extends Equatable {
  /// Nivel de zoom (6-16 recomendado para eventos)
  final int z;

  /// Coordenada X del tile (columna)
  final int x;

  /// Coordenada Y del tile (fila)
  final int y;

  const TileCoords({required this.z, required this.x, required this.y});

  /// Clave única para este tile
  String get key => '$z/$x/$y';

  /// Convierte a Map para serialización
  Map<String, dynamic> toMap() {
    return {'z': z, 'x': x, 'y': y};
  }

  /// Crea desde Map
  factory TileCoords.fromMap(Map<String, dynamic> map) {
    return TileCoords(
      z: map['z'] as int,
      x: map['x'] as int,
      y: map['y'] as int,
    );
  }

  @override
  List<Object?> get props => [z, x, y];

  @override
  String toString() => 'TileCoords(z: $z, x: $x, y: $y)';
}
