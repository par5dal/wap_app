// lib/features/upgrade_to_promoter/domain/repositories/upgrade_to_promoter_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';

abstract class UpgradeToPromoterRepository {
  Future<Either<Failure, void>> upgradeToPromoter();
}
