// lib/features/reports/domain/usecases/create_report.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/reports/data/datasources/reports_remote_data_source.dart';

class CreateReportParams {
  final String? eventId;
  final String? reportedUserId;
  final String reason;
  final String? description;

  const CreateReportParams({
    this.eventId,
    this.reportedUserId,
    required this.reason,
    this.description,
  }) : assert(
         eventId != null || reportedUserId != null,
         'Either eventId or reportedUserId must be provided',
       );
}

class CreateReportUseCase {
  final ReportsRemoteDataSource dataSource;

  CreateReportUseCase(this.dataSource);

  Future<Either<Failure, void>> call(CreateReportParams params) async {
    try {
      if (params.eventId != null) {
        await dataSource.createEventReport(
          eventId: params.eventId!,
          reason: params.reason,
          description: params.description,
        );
      } else {
        await dataSource.createUserReport(
          reportedUserId: params.reportedUserId!,
          reason: params.reason,
          description: params.description,
        );
      }
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in CreateReportUseCase', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in CreateReportUseCase', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
