// lib/features/manage_event/presentation/bloc/manage_event_event.dart

part of 'manage_event_bloc.dart';

abstract class ManageEventEvent extends Equatable {
  const ManageEventEvent();
  @override
  List<Object?> get props => [];
}

class ManageEventInitialized extends ManageEventEvent {
  final String? editEventId;
  const ManageEventInitialized({this.editEventId});
  @override
  List<Object?> get props => [editEventId];
}

class ManageEventStepChanged extends ManageEventEvent {
  final int step;
  const ManageEventStepChanged(this.step);
  @override
  List<Object?> get props => [step];
}

class ManageEventDetailsUpdated extends ManageEventEvent {
  final String title;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final double price;
  final List<String> categoryIds;

  const ManageEventDetailsUpdated({
    required this.title,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.price,
    required this.categoryIds,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    startDatetime,
    endDatetime,
    price,
    categoryIds,
  ];
}

class ManageEventVenueSelected extends ManageEventEvent {
  final SelectedVenue venue;
  const ManageEventVenueSelected(this.venue);
  @override
  List<Object?> get props => [venue];
}

class ManageEventVenueCleared extends ManageEventEvent {
  const ManageEventVenueCleared();
}

class ManageEventImageAdded extends ManageEventEvent {
  final EventImageData image;
  const ManageEventImageAdded(this.image);
  @override
  List<Object?> get props => [image];
}

class ManageEventImageRemoved extends ManageEventEvent {
  final String localId;
  const ManageEventImageRemoved(this.localId);
  @override
  List<Object?> get props => [localId];
}

class ManageEventPrimaryImageSet extends ManageEventEvent {
  final String localId;
  const ManageEventPrimaryImageSet(this.localId);
  @override
  List<Object?> get props => [localId];
}

class ManageEventImagesReordered extends ManageEventEvent {
  final List<EventImageData> images;
  const ManageEventImagesReordered(this.images);
  @override
  List<Object?> get props => [images];
}

class ManageEventSubmitRequested extends ManageEventEvent {
  final bool publish;
  const ManageEventSubmitRequested({required this.publish});
  @override
  List<Object?> get props => [publish];
}
