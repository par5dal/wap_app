// lib/features/profile/domain/usecases/get_my_profile.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';

class GetMyProfileUseCase {
  final ProfileRepository repository;

  GetMyProfileUseCase(this.repository);

  Future<Either<Failure, UserWithProfileEntity>> call() async {
    return await repository.getMyProfile();
  }
}
