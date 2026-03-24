// lib/features/profile/domain/usecases/update_my_profile.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateMyProfileUseCase {
  final ProfileRepository repository;

  UpdateMyProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(
    Map<String, dynamic> profileData,
  ) async {
    return await repository.updateMyProfile(profileData);
  }
}
