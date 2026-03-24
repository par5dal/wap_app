// lib/features/promoter_profile/domain/usecases/get_promoter_profile.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/promoter_profile/domain/entities/promoter_profile.dart';
import 'package:wap_app/features/promoter_profile/domain/repositories/promoter_repository.dart';

class GetPromoterProfileUseCase {
  final PromoterRepository repository;

  GetPromoterProfileUseCase(this.repository);

  Future<Either<Failure, PromoterProfile>> call(String promoterId) async {
    return await repository.getPromoterProfile(promoterId);
  }
}
