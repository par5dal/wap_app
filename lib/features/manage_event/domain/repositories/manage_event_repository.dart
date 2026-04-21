// lib/features/manage_event/domain/repositories/manage_event_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/manage_event/domain/entities/category_entity.dart';
import 'package:wap_app/features/manage_event/domain/entities/saved_venue_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';

abstract class ManageEventRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<SavedVenueEntity>>> getMyVenues({
    int page = 1,
    int limit = 5,
  });

  Future<Either<Failure, MyEventEntity>> getEventById(String eventId);

  /// Returns created event id
  Future<Either<Failure, String>> createEvent(Map<String, dynamic> payload);

  Future<Either<Failure, void>> updateEvent(
    String eventId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, void>> submitEventForReview(String eventId);

  Future<Either<Failure, void>> unpublishEvent(String eventId);

  /// Returns { signature, timestamp, api_key, folder }
  Future<Either<Failure, Map<String, dynamic>>> getUploadSignature({
    required String preset,
    String? eventId,
  });
}
