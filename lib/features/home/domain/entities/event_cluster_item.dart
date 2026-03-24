import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';

/// Wrapper para Event que implementa ClusterItem
/// Permite que los eventos funcionen con google_maps_cluster_manager
class EventClusterItem with ClusterItem {
  final Event event;

  EventClusterItem(this.event);

  @override
  LatLng get location => LatLng(event.latitude, event.longitude);

  @override
  String get geohash => '${event.latitude}_${event.longitude}';

  // Getters convenientes para acceder a los datos del evento
  String get id => event.id;
  String get title => event.title;
  String? get categorySlug => event.categorySlug;
  String? get categorySvg => event.categorySvg;
  double get latitude => event.latitude;
  double get longitude => event.longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventClusterItem &&
          runtimeType == other.runtimeType &&
          event.id == other.event.id;

  @override
  int get hashCode => event.id.hashCode;
}
