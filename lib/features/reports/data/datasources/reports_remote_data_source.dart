// lib/features/reports/data/datasources/reports_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/utils/app_logger.dart';

abstract class ReportsRemoteDataSource {
  /// Crea un reporte sobre un evento. [reason] es el código de motivo.
  Future<void> createEventReport({
    required String eventId,
    required String reason,
    String? description,
  });

  /// Crea un reporte sobre un usuario/promotor. [reason] es el código de motivo.
  Future<void> createUserReport({
    required String reportedUserId,
    required String reason,
    String? description,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio;

  ReportsRemoteDataSourceImpl({required this.dio});

  Future<void> _postReport(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('/reports', data: body);
      if (response.statusCode == 409) return; // Ya reportado, aceptable
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerException(
          message: 'Error al enviar el reporte',
          statusCode: response.statusCode,
          code: 'report_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 409) return; // Ya reportado, aceptable
      AppLogger.error('DioException in createReport', e, stackTrace);
      throw ServerException(
        message:
            e.response?.data?['message']?.toString() ??
            'Error al enviar el reporte',
        statusCode: e.response?.statusCode,
        code: 'report_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> createEventReport({
    required String eventId,
    required String reason,
    String? description,
  }) async {
    await _postReport({
      'reported_event_id': eventId,
      'reason': reason,
      if (description != null && description.isNotEmpty)
        'description': description,
    });
  }

  @override
  Future<void> createUserReport({
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    await _postReport({
      'reported_user_id': reportedUserId,
      'reason': reason,
      if (description != null && description.isNotEmpty)
        'description': description,
    });
  }
}
