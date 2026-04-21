// lib/features/manage_event/domain/usecases/get_upload_signature_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/manage_event/domain/repositories/manage_event_repository.dart';

class GetUploadSignatureUseCase {
  final ManageEventRepository repository;
  GetUploadSignatureUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String preset,
    String? eventId,
  }) async {
    return await repository.getUploadSignature(
      preset: preset,
      eventId: eventId,
    );
  }
}
