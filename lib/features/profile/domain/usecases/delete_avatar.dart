// lib/features/profile/domain/usecases/delete_avatar.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';

class DeleteAvatarUseCase {
  final ProfileRepository repository;

  DeleteAvatarUseCase(this.repository);

  Future<Either<Failure, void>> call(String avatarUrl) async {
    return await repository.deleteResource(avatarUrl);
  }
}
