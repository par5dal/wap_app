// lib/features/manage_event/domain/entities/event_form_data.dart

import 'dart:io';
import 'package:equatable/equatable.dart';

/// Represents an image in the wizard (local file or already-uploaded URL)
class EventImageData extends Equatable {
  final String? localId; // temp UUID for reordering
  final File? localFile; // null if already uploaded
  final String? uploadedUrl; // null if not yet uploaded
  final bool isPrimary;

  const EventImageData({
    this.localId,
    this.localFile,
    this.uploadedUrl,
    this.isPrimary = false,
  });

  bool get isUploaded => uploadedUrl != null;

  EventImageData copyWith({
    String? localId,
    File? localFile,
    String? uploadedUrl,
    bool? isPrimary,
  }) {
    return EventImageData(
      localId: localId ?? this.localId,
      localFile: localFile ?? this.localFile,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  List<Object?> get props => [localId, uploadedUrl, isPrimary];
}

/// Venue selected by the user
class SelectedVenue extends Equatable {
  final String? id; // from saved venues, null if from Mapbox search
  final String name;
  final String address;
  final double lat;
  final double lng;

  const SelectedVenue({
    this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [id, name, address, lat, lng];
}

/// All data collected through the wizard
class EventFormData extends Equatable {
  final String title;
  final String description;
  final DateTime? startDatetime;
  final DateTime? endDatetime;
  final double? price;
  final List<String> categoryIds;
  final SelectedVenue? venue;
  final List<EventImageData> images;

  const EventFormData({
    this.title = '',
    this.description = '',
    this.startDatetime,
    this.endDatetime,
    this.price,
    this.categoryIds = const [],
    this.venue,
    this.images = const [],
  });

  EventFormData copyWith({
    String? title,
    String? description,
    DateTime? startDatetime,
    DateTime? endDatetime,
    double? price,
    List<String>? categoryIds,
    SelectedVenue? venue,
    List<EventImageData>? images,
    bool clearVenue = false,
  }) {
    return EventFormData(
      title: title ?? this.title,
      description: description ?? this.description,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      price: price ?? this.price,
      categoryIds: categoryIds ?? this.categoryIds,
      venue: clearVenue ? null : (venue ?? this.venue),
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    startDatetime,
    endDatetime,
    price,
    categoryIds,
    venue,
    images,
  ];
}
