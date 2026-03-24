// test/features/auth/domain/usecases/get_legal_document_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/features/auth/domain/usecases/get_legal_document.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetLegalDocumentUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetLegalDocumentUseCase(mockRepository);
  });

  const tType = 'terms';
  const tLang = 'en';

  final tLegalDocument = LegalDocument(
    id: 'terms-1.0-en',
    version: '1.0',
    type: 'terms',
    lang: 'en',
    effectiveDate: DateTime(2024, 1, 15),
    sections: const [
      LegalSection(
        id: 'intro',
        title: '1. Introduction',
        content: '**Bold** text',
      ),
    ],
  );

  group('GetLegalDocumentUseCase', () {
    test('should call repository with correct parameters', () async {
      // Arrange
      when(
        () => mockRepository.getLegalDocument(tType, tLang),
      ).thenAnswer((_) async => Right(tLegalDocument));

      // Act
      await useCase(type: tType, lang: tLang);

      // Assert
      verify(() => mockRepository.getLegalDocument(tType, tLang)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return Right(LegalDocument) when repository succeeds',
      () async {
        // Arrange
        when(
          () => mockRepository.getLegalDocument(tType, tLang),
        ).thenAnswer((_) async => Right(tLegalDocument));

        // Act
        final result = await useCase(type: tType, lang: tLang);

        // Assert
        expect(result, Right<Failure, LegalDocument>(tLegalDocument));
      },
    );

    test('should return Left(failure) when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure(
        message: 'Error al obtener documento legal',
        statusCode: 500,
      );
      when(
        () => mockRepository.getLegalDocument(tType, tLang),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(type: tType, lang: tLang);

      // Assert
      expect(result, const Left<Failure, LegalDocument>(tFailure));
    });

    test('should fetch Spanish terms when lang is es', () async {
      // Arrange
      const tSpanishLang = 'es';
      when(
        () => mockRepository.getLegalDocument(tType, tSpanishLang),
      ).thenAnswer((_) async => Right(tLegalDocument));

      // Act
      await useCase(type: tType, lang: tSpanishLang);

      // Assert
      verify(
        () => mockRepository.getLegalDocument(tType, tSpanishLang),
      ).called(1);
    });

    test('should fetch privacy policy when type is privacy', () async {
      // Arrange
      const tPrivacyType = 'privacy';
      when(
        () => mockRepository.getLegalDocument(tPrivacyType, tLang),
      ).thenAnswer((_) async => Right(tLegalDocument));

      // Act
      await useCase(type: tPrivacyType, lang: tLang);

      // Assert
      verify(
        () => mockRepository.getLegalDocument(tPrivacyType, tLang),
      ).called(1);
    });

    test('should return document with multiple sections', () async {
      // Arrange
      final tDocumentWithSections = LegalDocument(
        id: 'terms-1.0-en',
        version: '1.0',
        type: 'terms',
        lang: 'en',
        effectiveDate: DateTime(2024, 1, 15),
        sections: const [
          LegalSection(
            id: 'intro',
            title: '1. Introduction',
            content: 'Introduction text',
          ),
          LegalSection(
            id: 'usage',
            title: '2. Usage',
            content: 'Usage policy text',
          ),
          LegalSection(
            id: 'liability',
            title: '3. Liability',
            content: 'Liability disclaimer text',
          ),
        ],
      );

      when(
        () => mockRepository.getLegalDocument(tType, tLang),
      ).thenAnswer((_) async => Right(tDocumentWithSections));

      // Act
      final result = await useCase(type: tType, lang: tLang);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should return Right'), (document) {
        expect(document.sections, hasLength(3));
        expect(document.sections[0].id, 'intro');
        expect(document.sections[1].id, 'usage');
        expect(document.sections[2].id, 'liability');
      });
    });

    test('should handle various error types', () async {
      // Arrange
      const tNetworkFailure = NetworkFailure(message: 'Network error');
      when(
        () => mockRepository.getLegalDocument(tType, tLang),
      ).thenAnswer((_) async => const Left(tNetworkFailure));

      // Act
      final result = await useCase(type: tType, lang: tLang);

      // Assert
      expect(result, const Left<Failure, LegalDocument>(tNetworkFailure));
    });

    test(
      'should preserve document metadata when returning from repository',
      () async {
        // Arrange
        final tDocument = LegalDocument(
          id: 'privacy-2.0-es',
          version: '2.0',
          type: 'privacy',
          lang: 'es',
          effectiveDate: DateTime(2024, 6, 1),
          sections: const [
            LegalSection(
              id: 'privacy',
              title: 'Política de Privacidad',
              content: 'Contenido de privacidad',
            ),
          ],
        );

        when(
          () => mockRepository.getLegalDocument('privacy', 'es'),
        ).thenAnswer((_) async => Right(tDocument));

        // Act
        final result = await useCase(type: 'privacy', lang: 'es');

        // Assert
        result.fold((failure) => fail('Should return Right'), (document) {
          expect(document.id, 'privacy-2.0-es');
          expect(document.version, '2.0');
          expect(document.type, 'privacy');
          expect(document.lang, 'es');
          expect(document.effectiveDate, DateTime(2024, 6, 1));
        });
      },
    );
  });
}
