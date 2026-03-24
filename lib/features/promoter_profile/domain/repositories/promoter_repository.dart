// lib/features/promoter_profile/domain/repositories/promoter_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/promoter_profile/domain/entities/promoter_profile.dart';

abstract class PromoterRepository {
  Future<Either<Failure, PromoterProfile>> getPromoterProfile(
    String promoterId,
  );

  Future<Either<Failure, List<Event>>> getPromoterEvents({
    required String promoterId,
    int page = 1,
    int limit = 10,
    double? userLatitude,
    double? userLongitude,
  });
}
