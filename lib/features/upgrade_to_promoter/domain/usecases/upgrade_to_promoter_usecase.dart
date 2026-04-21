// lib/features/upgrade_to_promoter/domain/usecases/upgrade_to_promoter_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/upgrade_to_promoter/domain/repositories/upgrade_to_promoter_repository.dart';

class UpgradeToPromoterUseCase {
  final UpgradeToPromoterRepository repository;

  UpgradeToPromoterUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.upgradeToPromoter();
  }
}
