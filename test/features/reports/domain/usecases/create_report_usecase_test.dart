// test/features/reports/domain/usecases/create_report_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:wap_app/features/reports/domain/usecases/create_report.dart';

class MockReportsRemoteDataSource extends Mock
    implements ReportsRemoteDataSource {}

void main() {
  late CreateReportUseCase useCase;
  late MockReportsRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockReportsRemoteDataSource();
    useCase = CreateReportUseCase(mockDataSource);
  });

  const tEventId = 'event-123';
  const tUserId = 'user-456';
  const tReason = 'SPAM';
  const tDescription = 'Hay contenido inapropiado';

  group('event report', () {
    test('returns Right(null) on success', () async {
      when(
        () => mockDataSource.createEventReport(
          eventId: tEventId,
          reason: tReason,
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async {});

      final result = await useCase(
        const CreateReportParams(eventId: tEventId, reason: tReason),
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => mockDataSource.createEventReport(
          eventId: tEventId,
          reason: tReason,
          description: null,
        ),
      ).called(1);
    });

    test('passes optional description to datasource', () async {
      when(
        () => mockDataSource.createEventReport(
          eventId: tEventId,
          reason: tReason,
          description: tDescription,
        ),
      ).thenAnswer((_) async {});

      await useCase(
        const CreateReportParams(
          eventId: tEventId,
          reason: tReason,
          description: tDescription,
        ),
      );

      verify(
        () => mockDataSource.createEventReport(
          eventId: tEventId,
          reason: tReason,
          description: tDescription,
        ),
      ).called(1);
    });
  });

  group('user report', () {
    test('returns Right(null) on success', () async {
      when(
        () => mockDataSource.createUserReport(
          reportedUserId: tUserId,
          reason: tReason,
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async {});

      final result = await useCase(
        const CreateReportParams(reportedUserId: tUserId, reason: tReason),
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => mockDataSource.createUserReport(
          reportedUserId: tUserId,
          reason: tReason,
          description: null,
        ),
      ).called(1);
    });
  });

  group('error handling', () {
    test('maps ServerException to Left(ServerFailure)', () async {
      when(
        () => mockDataSource.createEventReport(
          eventId: any(named: 'eventId'),
          reason: any(named: 'reason'),
          description: any(named: 'description'),
        ),
      ).thenThrow(
        const ServerException(message: 'Error del servidor', statusCode: 500),
      );

      final result = await useCase(
        const CreateReportParams(eventId: tEventId, reason: tReason),
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Error del servidor');
      }, (_) => fail('Expected Left'));
    });

    test('maps unexpected exception to Left(UnknownFailure)', () async {
      when(
        () => mockDataSource.createUserReport(
          reportedUserId: any(named: 'reportedUserId'),
          reason: any(named: 'reason'),
          description: any(named: 'description'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      final result = await useCase(
        const CreateReportParams(reportedUserId: tUserId, reason: tReason),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
