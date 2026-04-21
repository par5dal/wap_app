// test/features/auth/data/repositories/auth_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wap_app/features/auth/data/models/legal_document_model.dart';
import 'package:wap_app/features/auth/data/models/token_model.dart';
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

  // ─── login ────────────────────────────────────────────────────────────────
  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tToken = TokenModel(isNewUser: false);

    test('returns Right(TokenEntity) on success', () async {
      when(
        () => mockRemoteDataSource.login(tEmail, tPassword),
      ).thenAnswer((_) async => tToken);

      final result = await repository.login(tEmail, tPassword);

      expect(result.isRight(), true);
      verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => mockRemoteDataSource.login(tEmail, tPassword)).thenThrow(
        const ServerException(message: 'Unauthorized', statusCode: 401),
      );

      final result = await repository.login(tEmail, tPassword);

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left on generic exception', () async {
      when(
        () => mockRemoteDataSource.login(tEmail, tPassword),
      ).thenThrow(Exception('Network error'));

      final result = await repository.login(tEmail, tPassword);

      expect(result.isLeft(), true);
    });
  });

  // ─── register ────────────────────────────────────────────────────────────
  group('register', () {
    const tEmail = 'new@example.com';
    const tPassword = 'secret';
    const tFirst = 'John';
    const tLast = 'Doe';
    final tToken = TokenModel(isNewUser: true);

    test('returns Right(TokenEntity) on success', () async {
      when(
        () => mockRemoteDataSource.register(tEmail, tPassword, tFirst, tLast),
      ).thenAnswer((_) async => tToken);

      final result = await repository.register(
        tEmail,
        tPassword,
        tFirst,
        tLast,
      );

      expect(result.isRight(), true);
      result.fold(
        (f) => fail('Expected Right'),
        (t) => expect(t.isNewUser, true),
      );
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.register(any(), any(), any(), any()),
      ).thenThrow(const ServerException(message: 'Conflict', statusCode: 409));

      final result = await repository.register(
        tEmail,
        tPassword,
        tFirst,
        tLast,
      );

      expect(result.isLeft(), true);
    });
  });

  // ─── loginWithGoogle ─────────────────────────────────────────────────────
  group('loginWithGoogle', () {
    test('returns Right on success', () async {
      when(
        () => mockRemoteDataSource.loginWithGoogle(),
      ).thenAnswer((_) async => TokenModel());

      final result = await repository.loginWithGoogle();
      expect(result.isRight(), true);
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.loginWithGoogle(),
      ).thenThrow(const AuthenticationException(message: 'Google cancelled'));

      final result = await repository.loginWithGoogle();
      expect(result.isLeft(), true);
    });
  });

  // ─── loginWithApple ──────────────────────────────────────────────────────
  group('loginWithApple', () {
    test('returns Right on success', () async {
      when(
        () => mockRemoteDataSource.loginWithApple(),
      ).thenAnswer((_) async => TokenModel());

      final result = await repository.loginWithApple();
      expect(result.isRight(), true);
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.loginWithApple(),
      ).thenThrow(const AuthenticationException(message: 'Apple cancelled'));

      final result = await repository.loginWithApple();
      expect(result.isLeft(), true);
    });
  });

  // ─── logout ──────────────────────────────────────────────────────────────
  group('logout', () {
    test('returns Right(null) on success', () async {
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async {});

      final result = await repository.logout();
      expect(result.isRight(), true);
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.logout(),
      ).thenThrow(const ServerException(message: 'Logout error'));

      final result = await repository.logout();
      expect(result.isLeft(), true);
    });
  });

  // ─── checkEmailExists ─────────────────────────────────────────────────────
  group('checkEmailExists', () {
    const tEmail = 'existing@example.com';

    test('returns Right(true) when email exists', () async {
      when(
        () => mockRemoteDataSource.checkEmailExists(tEmail),
      ).thenAnswer((_) async => true);

      final result = await repository.checkEmailExists(tEmail);
      expect(result.isRight(), true);
      result.fold((_) => fail('Right expected'), (v) => expect(v, true));
    });

    test('returns Right(false) when email does not exist', () async {
      when(
        () => mockRemoteDataSource.checkEmailExists(tEmail),
      ).thenAnswer((_) async => false);

      final result = await repository.checkEmailExists(tEmail);
      result.fold((_) => fail('Right expected'), (v) => expect(v, false));
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.checkEmailExists(any()),
      ).thenThrow(const ServerException(message: 'Server error'));

      final result = await repository.checkEmailExists(tEmail);
      expect(result.isLeft(), true);
    });
  });

  // ─── getTermsInfo ─────────────────────────────────────────────────────────
  group('getTermsInfo', () {
    test('returns Right(version) on success', () async {
      when(
        () => mockRemoteDataSource.getTermsInfo(),
      ).thenAnswer((_) async => '1.2');

      final result = await repository.getTermsInfo();
      result.fold((_) => fail('Right expected'), (v) => expect(v, '1.2'));
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.getTermsInfo(),
      ).thenThrow(const ServerException(message: 'Server error'));

      final result = await repository.getTermsInfo();
      expect(result.isLeft(), true);
    });
  });

  // ─── acceptTerms ──────────────────────────────────────────────────────────
  group('acceptTerms', () {
    test('returns Right(null) on success', () async {
      when(
        () => mockRemoteDataSource.acceptTerms(any()),
      ).thenAnswer((_) async {});

      final result = await repository.acceptTerms('1.2');
      expect(result.isRight(), true);
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.acceptTerms(any()),
      ).thenThrow(const ServerException(message: 'Server error'));

      final result = await repository.acceptTerms('1.2');
      expect(result.isLeft(), true);
    });
  });

  // ─── createProfile ────────────────────────────────────────────────────────
  group('createProfile', () {
    test('returns Right(null) on success', () async {
      when(
        () => mockRemoteDataSource.createProfile(any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.createProfile('John', 'Doe');
      expect(result.isRight(), true);
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.createProfile(any(), any()),
      ).thenThrow(const ServerException(message: 'Error'));

      final result = await repository.createProfile('John', 'Doe');
      expect(result.isLeft(), true);
    });
  });

  // ─── checkUserStatus ──────────────────────────────────────────────────────
  group('checkUserStatus', () {
    test('returns Right(null) on success', () async {
      when(
        () => mockRemoteDataSource.checkUserStatus(),
      ).thenAnswer((_) async {});

      final result = await repository.checkUserStatus();
      expect(result.isRight(), true);
    });

    test('returns Left on exception', () async {
      when(
        () => mockRemoteDataSource.checkUserStatus(),
      ).thenThrow(const ServerException(message: 'Error'));

      final result = await repository.checkUserStatus();
      expect(result.isLeft(), true);
    });
  });
}
