// lib/features/profile/domain/usecases/upload_avatar.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(File imageFile) async {
    try {
      // 1. Obtener firma del backend
      final signatureResult = await repository.getUploadSignature(
        preset: 'wap_avatars',
        uploadType: 'avatar',
      );

      // Extraer resultado de forma imperativa (evita async dentro de fold)
      Map<String, dynamic>? signatureData;
      Failure? signatureFailure;
      signatureResult.fold(
        (f) => signatureFailure = f,
        (d) => signatureData = d,
      );
      if (signatureFailure != null) return Left(signatureFailure!);

      // 2. Subir imagen a Cloudinary con la firma
      // cloud_name puede venir del backend o del .env como fallback
      final cloudName =
          signatureData!['cloud_name'] as String? ??
          dotenv.env['CLOUDINARY_CLOUD_NAME'];

      if (cloudName == null || cloudName.isEmpty) {
        return const Left(
          ServerFailure(message: 'Configuración de Cloudinary no encontrada'),
        );
      }

      final uploadUrl =
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      // El folder viene firmado por el backend — Cloudinary rechaza cualquier
      // intento de subir a una carpeta diferente a la firmada.
      final folder = signatureData!['folder'] as String? ?? '';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': 'wap_avatars',
        'timestamp': signatureData!['timestamp'],
        'signature': signatureData!['signature'],
        'api_key': signatureData!['api_key'],
        if (folder.isNotEmpty) 'folder': folder,
      });

      try {
        final dio = Dio();
        final response = await dio.post(uploadUrl, data: formData);

        if (response.statusCode == 200) {
          // Guardamos la URL base sin transformaciones para facilitar el borrado
          final secureUrl = response.data['secure_url'] as String;
          final urlWithoutTransformations = secureUrl.replaceFirst(
            RegExp(r'/upload/[^/]+/v\d+/'),
            '/upload/v${response.data['version']}/',
          );
          return Right(urlWithoutTransformations);
        } else {
          return const Left(ServerFailure(message: 'Error al subir imagen'));
        }
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: 'Error de conexión al subir imagen: ${e.message}',
          ),
        );
      }
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
