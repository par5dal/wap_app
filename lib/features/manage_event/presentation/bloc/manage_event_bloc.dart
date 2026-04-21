// lib/features/manage_event/presentation/bloc/manage_event_bloc.dart

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/manage_event/domain/entities/category_entity.dart';
import 'package:wap_app/features/manage_event/domain/entities/event_form_data.dart';
import 'package:wap_app/features/manage_event/domain/entities/saved_venue_entity.dart';
import 'package:wap_app/features/manage_event/domain/usecases/get_categories_usecase.dart';
import 'package:wap_app/features/manage_event/domain/usecases/get_my_venues_usecase.dart';
import 'package:wap_app/features/manage_event/domain/usecases/get_upload_signature_usecase.dart';
import 'package:wap_app/features/manage_event/domain/usecases/save_event_usecase.dart';
import 'package:wap_app/features/manage_event/domain/repositories/manage_event_repository.dart';

part 'manage_event_event.dart';
part 'manage_event_state.dart';

class ManageEventBloc extends Bloc<ManageEventEvent, ManageEventState> {
  final GetCategoriesUseCase getCategories;
  final GetMyVenuesUseCase getMyVenues;
  final SaveEventUseCase saveEvent;
  final GetUploadSignatureUseCase getUploadSignature;
  final ManageEventRepository repository;

  ManageEventBloc({
    required this.getCategories,
    required this.getMyVenues,
    required this.saveEvent,
    required this.getUploadSignature,
    required this.repository,
  }) : super(const ManageEventState()) {
    on<ManageEventInitialized>(_onInitialized);
    on<ManageEventStepChanged>(_onStepChanged);
    on<ManageEventDetailsUpdated>(_onDetailsUpdated);
    on<ManageEventVenueSelected>(_onVenueSelected);
    on<ManageEventVenueCleared>(_onVenueCleared);
    on<ManageEventImageAdded>(_onImageAdded);
    on<ManageEventImageRemoved>(_onImageRemoved);
    on<ManageEventPrimaryImageSet>(_onPrimaryImageSet);
    on<ManageEventImagesReordered>(_onImagesReordered);
    on<ManageEventSubmitRequested>(_onSubmitRequested);
  }

  Future<void> _onInitialized(
    ManageEventInitialized event,
    Emitter<ManageEventState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ManageEventStatus.loading,
        isEditMode: event.editEventId != null,
        editEventId: event.editEventId,
      ),
    );

    // Load categories and saved venues in parallel
    final catsResult = await getCategories();
    final venuesResult = await getMyVenues(page: 1, limit: 100);

    final cats = catsResult.fold((_) => <CategoryEntity>[], (c) => c);
    final venues = venuesResult.fold((_) => <SavedVenueEntity>[], (v) => v);

    if (event.editEventId != null) {
      final eventResult = await repository.getEventById(event.editEventId!);
      eventResult.fold(
        (failure) => emit(
          state.copyWith(
            status: ManageEventStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (entity) {
          final formData = EventFormData(
            title: entity.title,
            description: entity.description ?? '',
            startDatetime: entity.startDatetime,
            endDatetime: entity.endDatetime,
            price: entity.price,
            categoryIds: entity.categoryIds,
            venue: entity.venueName != null
                ? SelectedVenue(
                    name: entity.venueName!,
                    address: entity.venueAddress ?? '',
                    lat: entity.venueLatitude ?? 0,
                    lng: entity.venueLongitude ?? 0,
                  )
                : null,
            images: entity.imageUrls
                .asMap()
                .entries
                .map(
                  (e) => EventImageData(
                    localId: 'existing_${e.key}',
                    uploadedUrl: e.value,
                    isPrimary: e.key == 0,
                  ),
                )
                .toList(),
          );
          emit(
            state.copyWith(
              status: ManageEventStatus.ready,
              categories: cats,
              savedVenues: venues,
              formData: formData,
              moderationStatus: entity.moderationStatus,
              moderationComment: entity.moderationComment,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          status: ManageEventStatus.ready,
          categories: cats,
          savedVenues: venues,
        ),
      );
    }
  }

  void _onStepChanged(
    ManageEventStepChanged event,
    Emitter<ManageEventState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onDetailsUpdated(
    ManageEventDetailsUpdated event,
    Emitter<ManageEventState> emit,
  ) {
    emit(
      state.copyWith(
        formData: state.formData.copyWith(
          title: event.title,
          description: event.description,
          startDatetime: event.startDatetime,
          endDatetime: event.endDatetime,
          price: event.price,
          categoryIds: event.categoryIds,
        ),
      ),
    );
  }

  void _onVenueSelected(
    ManageEventVenueSelected event,
    Emitter<ManageEventState> emit,
  ) {
    emit(state.copyWith(formData: state.formData.copyWith(venue: event.venue)));
  }

  void _onVenueCleared(
    ManageEventVenueCleared event,
    Emitter<ManageEventState> emit,
  ) {
    emit(state.copyWith(formData: state.formData.copyWith(clearVenue: true)));
  }

  void _onImageAdded(
    ManageEventImageAdded event,
    Emitter<ManageEventState> emit,
  ) {
    final updated = List<EventImageData>.from(state.formData.images)
      ..add(event.image);
    // First image is always primary
    final withPrimary = _setPrimary(updated);
    emit(
      state.copyWith(formData: state.formData.copyWith(images: withPrimary)),
    );
  }

  void _onImageRemoved(
    ManageEventImageRemoved event,
    Emitter<ManageEventState> emit,
  ) {
    final updated = state.formData.images
        .where((i) => i.localId != event.localId)
        .toList();
    final withPrimary = _setPrimary(updated);
    emit(
      state.copyWith(formData: state.formData.copyWith(images: withPrimary)),
    );
  }

  void _onPrimaryImageSet(
    ManageEventPrimaryImageSet event,
    Emitter<ManageEventState> emit,
  ) {
    final updated = state.formData.images
        .map((i) => i.copyWith(isPrimary: i.localId == event.localId))
        .toList();
    emit(state.copyWith(formData: state.formData.copyWith(images: updated)));
  }

  void _onImagesReordered(
    ManageEventImagesReordered event,
    Emitter<ManageEventState> emit,
  ) {
    final withPrimary = _setPrimary(event.images);
    emit(
      state.copyWith(formData: state.formData.copyWith(images: withPrimary)),
    );
  }

  List<EventImageData> _setPrimary(List<EventImageData> images) {
    if (images.isEmpty) return images;
    return [
      images.first.copyWith(isPrimary: true),
      ...images.skip(1).map((i) => i.copyWith(isPrimary: false)),
    ];
  }

  Future<void> _onSubmitRequested(
    ManageEventSubmitRequested event,
    Emitter<ManageEventState> emit,
  ) async {
    emit(state.copyWith(status: ManageEventStatus.submitting));

    try {
      // 1. Upload local images to Cloudinary
      final eventFolderId = state.editEventId ?? _generateFolderId();
      final uploadedImages = await _uploadImages(eventFolderId);

      // 2. Build payload
      final formData = state.formData;
      final payload = <String, dynamic>{
        'title': formData.title,
        'description': formData.description,
        'start_datetime': formData.startDatetime!.toIso8601String(),
        'end_datetime': formData.endDatetime!.toIso8601String(),
        'price': formData.price ?? 0,
        'category_ids': formData.categoryIds,
        if (formData.venue != null)
          'venueData': {
            'name': formData.venue!.name,
            'address': formData.venue!.address,
            'lat': formData.venue!.lat,
            'lng': formData.venue!.lng,
          },
        if (uploadedImages.isNotEmpty)
          'images': uploadedImages
              .map(
                (img) => {'url': img.uploadedUrl, 'is_primary': img.isPrimary},
              )
              .toList(),
      };

      // 3. Create or update event
      final saveResult = await saveEvent(
        eventId: state.editEventId,
        payload: payload,
      );

      await saveResult.fold(
        (failure) async => emit(
          state.copyWith(
            status: ManageEventStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (createdId) async {
          // 4. Optionally submit for review (publish)
          if (event.publish) {
            final reviewResult = await repository.submitEventForReview(
              createdId,
            );
            reviewResult.fold(
              (_) {}, // non-fatal: event saved, just not submitted
              (_) {},
            );
          } else if (state.editEventId != null) {
            // If updating and publish: false, unpublish the event
            final unpublishResult = await repository.unpublishEvent(createdId);
            unpublishResult.fold(
              (_) {}, // non-fatal: event saved, just not unpublished
              (_) {},
            );
          }
          emit(
            state.copyWith(
              status: ManageEventStatus.success,
              successEventId: createdId,
            ),
          );
        },
      );
    } catch (e, st) {
      AppLogger.error('Unexpected error in submit', e, st);
      emit(
        state.copyWith(
          status: ManageEventStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<List<EventImageData>> _uploadImages(String folderId) async {
    final result = <EventImageData>[];
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

    for (final image in state.formData.images) {
      if (image.isUploaded) {
        result.add(image);
        continue;
      }
      if (image.localFile == null) continue;

      try {
        final sigResult = await getUploadSignature(
          preset: 'wap_events',
          eventId: folderId,
        );
        final sig = sigResult.fold((_) => null, (s) => s);
        if (sig == null) {
          result.add(image);
          continue;
        }

        final uploadDio = sl<Dio>();
        final formPayload = FormData.fromMap({
          'file': await MultipartFile.fromFile(image.localFile!.path),
          'api_key': sig['api_key'],
          'timestamp': sig['timestamp'].toString(),
          'signature': sig['signature'],
          'upload_preset': 'wap_events',
          'folder': sig['folder'] ?? 'wap_events/$folderId',
        });

        final response = await uploadDio.post(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
          data: formPayload,
        );

        if (response.statusCode == 200) {
          final secureUrl = response.data['secure_url'] as String;
          result.add(image.copyWith(uploadedUrl: secureUrl));
        }
      } catch (e, st) {
        AppLogger.error('Error uploading image', e, st);
        // Skip failed image — don't block the whole submit
      }
    }

    return result;
  }

  String _generateFolderId() {
    return const Uuid().v4();
  }
}
