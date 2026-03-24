// test/features/auth/data/repositories/auth_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wap_app/features/auth/data/models/legal_document_model.dart';
import 'package:wap_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('AuthRepositoryImpl - getLegalDocument', () {
    const tType = 'terms';
    const tLang = 'en';

    final tLegalDocumentModel = LegalDocumentModel(
      id: 'terms-1.0-en',
      version: '1.0',
      type: 'terms',
      lang: 'en',
      effectiveDate: DateTime(2024, 1, 15),
      sections: const [
        LegalSectionModel(
          id: 'intro',
          title: '1. Introduction',
          content: '**Bold** text',
        ),
      ],
    );

    test(
      'should return Right(LegalDocument) when datasource succeeds',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getLegalDocument(tType, tLang),
        ).thenAnswer((_) async => tLegalDocumentModel);

        // Act
        final result = await repository.getLegalDocument(tType, tLang);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should return Right'), (document) {
          expect(document.id, tLegalDocumentModel.id);
          expect(document.version, tLegalDocumentModel.version);
          expect(document.type, tLegalDocumentModel.type);
          expect(document.lang, tLegalDocumentModel.lang);
        });
        verify(
          () => mockRemoteDataSource.getLegalDocument(tType, tLang),
        ).called(1);
      },
    );

    test(
      'should return Left(Failure) when datasource throws exception',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getLegalDocument(tType, tLang),
        ).thenThrow(ServerException(message: 'Server error', code: 'error'));

        // Act
        final result = await repository.getLegalDocument(tType, tLang);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<Failure>());
        }, (document) => fail('Should return Left'));
      },
    );

    test('should pass parameters correctly to datasource', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.getLegalDocument(any(), any()),
      ).thenAnswer((_) async => tLegalDocumentModel);

      // Act
      await repository.getLegalDocument(tType, tLang);

      // Assert
      verify(
        () => mockRemoteDataSource.getLegalDocument(tType, tLang),
      ).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should handle different document types (privacy)', () async {
      // Arrange
      const tPrivacyType = 'privacy';
      when(
        () => mockRemoteDataSource.getLegalDocument(tPrivacyType, tLang),
      ).thenAnswer((_) async => tLegalDocumentModel);

      // Act
      await repository.getLegalDocument(tPrivacyType, tLang);

      // Assert
      verify(
        () => mockRemoteDataSource.getLegalDocument(tPrivacyType, tLang),
      ).called(1);
    });

    test('should handle different languages', () async {
      // Arrange
      const tSpanishLang = 'es';
      when(
        () => mockRemoteDataSource.getLegalDocument(tType, tSpanishLang),
      ).thenAnswer((_) async => tLegalDocumentModel);

      // Act
      await repository.getLegalDocument(tType, tSpanishLang);

      // Assert
      verify(
        () => mockRemoteDataSource.getLegalDocument(tType, tSpanishLang),
      ).called(1);
    });

    test('should convert model to entity in the result', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.getLegalDocument(tType, tLang),
      ).thenAnswer((_) async => tLegalDocumentModel);

      // Act
      final result = await repository.getLegalDocument(tType, tLang);

      // Assert
      result.fold((failure) => fail('Should return Right'), (entity) {
        expect(entity.id, tLegalDocumentModel.id);
        expect(entity.sections.length, tLegalDocumentModel.sections.length);
      });
    });

    test('should handle document with multiple sections', () async {
      // Arrange
      final largeDocument = LegalDocumentModel(
        id: 'terms-1.0-en',
        version: '1.0',
        type: 'terms',
        lang: 'en',
        effectiveDate: DateTime(2024, 1, 15),
        sections: [
          const LegalSectionModel(
            id: 'sec1',
            title: 'Section 1',
            content: 'Content 1',
          ),
          const LegalSectionModel(
            id: 'sec2',
            title: 'Section 2',
            content: 'Content 2',
          ),
          const LegalSectionModel(
            id: 'sec3',
            title: 'Section 3',
            content: 'Content 3',
          ),
        ],
      );
      when(
        () => mockRemoteDataSource.getLegalDocument(tType, tLang),
      ).thenAnswer((_) async => largeDocument);

      // Act
      final result = await repository.getLegalDocument(tType, tLang);

      // Assert
      result.fold((failure) => fail('Should return Right'), (document) {
        expect(document.sections, hasLength(3));
      });
    });

    test('should handle various exception types', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.getLegalDocument(tType, tLang),
      ).thenThrow(Exception('Unknown error'));

      // Act
      final result = await repository.getLegalDocument(tType, tLang);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should preserve document metadata through conversion', () async {
      // Arrange
      final metadata = LegalDocumentModel(
        id: 'privacy-2.0-es',
        version: '2.0',
        type: 'privacy',
        lang: 'es',
        effectiveDate: DateTime(2024, 6, 1),
        sections: const [
          LegalSectionModel(
            id: 'p1',
            title: 'Privacidad',
            content: 'Datos privados',
          ),
        ],
      );
      when(
        () => mockRemoteDataSource.getLegalDocument('privacy', 'es'),
      ).thenAnswer((_) async => metadata);

      // Act
      final result = await repository.getLegalDocument('privacy', 'es');

      // Assert
      result.fold((failure) => fail('Should return Right'), (document) {
        expect(document.id, 'privacy-2.0-es');
        expect(document.version, '2.0');
        expect(document.type, 'privacy');
        expect(document.lang, 'es');
        expect(document.effectiveDate, DateTime(2024, 6, 1));
      });
    });
  });
}
