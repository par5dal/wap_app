// lib/features/manage_event/presentation/bloc/manage_event_state.dart

part of 'manage_event_bloc.dart';

enum ManageEventStatus {
  initial,
  loading, // loading categories/venues or event for edit
  ready, // wizard data ready for input
  submitting, // save/upload in progress
  success,
  failure,
}

class ManageEventState extends Equatable {
  final ManageEventStatus status;
  final int currentStep; // 0–3
  final bool isEditMode;
  final String? editEventId;
  final EventFormData formData;
  final List<CategoryEntity> categories;
  final List<SavedVenueEntity> savedVenues;
  final String? errorMessage;
  final String? successEventId;
  final String? moderationStatus;
  final String? moderationComment;

  const ManageEventState({
    this.status = ManageEventStatus.initial,
    this.currentStep = 0,
    this.isEditMode = false,
    this.editEventId,
    this.formData = const EventFormData(),
    this.categories = const [],
    this.savedVenues = const [],
    this.errorMessage,
    this.successEventId,
    this.moderationStatus,
    this.moderationComment,
  });

  ManageEventState copyWith({
    ManageEventStatus? status,
    int? currentStep,
    bool? isEditMode,
    String? editEventId,
    EventFormData? formData,
    List<CategoryEntity>? categories,
    List<SavedVenueEntity>? savedVenues,
    String? errorMessage,
    String? successEventId,
    String? moderationStatus,
    String? moderationComment,
  }) {
    return ManageEventState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      isEditMode: isEditMode ?? this.isEditMode,
      editEventId: editEventId ?? this.editEventId,
      formData: formData ?? this.formData,
      categories: categories ?? this.categories,
      savedVenues: savedVenues ?? this.savedVenues,
      errorMessage: errorMessage ?? this.errorMessage,
      successEventId: successEventId ?? this.successEventId,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationComment: moderationComment ?? this.moderationComment,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentStep,
    isEditMode,
    editEventId,
    formData,
    categories,
    savedVenues,
    errorMessage,
    successEventId,
    moderationStatus,
    moderationComment,
  ];
}
