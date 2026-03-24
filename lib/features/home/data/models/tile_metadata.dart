import 'package:equatable/equatable.dart';

/// Metadata del tile devuelta por el backend
class TileMetadata extends Equatable {
  final int eventCount;
  final bool cached;
  final String generatedAt;

  const TileMetadata({
    required this.eventCount,
    required this.cached,
    required this.generatedAt,
  });

  /// Crea desde JSON del backend
  factory TileMetadata.fromJson(Map<String, dynamic> json) {
    return TileMetadata(
      eventCount: json['event_count'] as int,
      cached: json['cached'] as bool,
      generatedAt: json['generated_at'] as String,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'event_count': eventCount,
      'cached': cached,
      'generated_at': generatedAt,
    };
  }

  @override
  List<Object?> get props => [eventCount, cached, generatedAt];

  @override
  String toString() =>
      'TileMetadata(eventCount: $eventCount, cached: $cached, generatedAt: $generatedAt)';
}
