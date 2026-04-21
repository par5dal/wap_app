// test/features/auth/data/datasources/auth_remote_data_source_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wap_app/features/auth/data/models/legal_document_model.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio: mockDio);
  });

  group('AuthRemoteDataSourceImpl - getLegalDocument', () {
    const tType = 'terms';
    const tLang = 'en';

    final tLegalDocumentJson = {
      'id': 'terms-1.0-en',
      'version': '1.0',
      'type': 'terms',
      'lang': 'en',
      'effective_date': '2024-01-15',
      'sections': [
        {
          'id': 'intro',
          'title': '1. Introduction',
          'content': '**Bold** text with *italic*',
        },
        {
          'id': 'usage',
          'title': '2. Usage',
          'content': 'This is our usage policy.',
        },
      ],
    };

    test(
      'should return LegalDocumentModel when response status is 200',
      () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(tLegalDocumentJson);
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getLegalDocument(tType, tLang);

        // Assert
        expect(result, isA<LegalDocumentModel>());
        expect(result.id, 'terms-1.0-en');
        expect(result.version, '1.0');
        expect(result.type, 'terms');
        expect(result.lang, 'en');
      },
    );

    test(
      'should return LegalDocumentModel when response status is 304 (cached)',
      () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(304);
        when(() => mockResponse.data).thenReturn(tLegalDocumentJson);
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getLegalDocument(tType, tLang);

        // Assert
        expect(result, isA<LegalDocumentModel>());
        expect(result.id, 'terms-1.0-en');
      },
    );

    test(
      'should throw ServerException when response status is not 200 or 304',
      () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(404);
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => dataSource.getLegalDocument(tType, tLang),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test('should throw ServerException when network error occurs', () async {
      // Arrange
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Connection timeout',
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getLegalDocument(tType, tLang),
        throwsA(isA<ServerException>()),
      );
    });

    test('should correctly format the endpoint URL', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tLegalDocumentJson);
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.getLegalDocument(tType, tLang);

      // Assert
      verify(
        () => mockDio.get(
          '/legal/terms',
          queryParameters: {'lang': 'en'},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('should pass correct query parameters for language', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tLegalDocumentJson);
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.getLegalDocument(tType, 'es');

      // Assert
      verify(
        () => mockDio.get(
          any(),
          queryParameters: {'lang': 'es'},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('should handle privacy policy documents', () async {
      // Arrange
      final mockResponse = MockResponse();
      final privacyJson = {...tLegalDocumentJson, 'type': 'privacy'};
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(privacyJson);
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getLegalDocument('privacy', tLang);

      // Assert
      expect(result.type, 'privacy');
      verify(
        () => mockDio.get(
          '/legal/privacy',
          queryParameters: {'lang': tLang},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('should return model with all sections parsed', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tLegalDocumentJson);
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getLegalDocument(tType, tLang);

      // Assert
      expect(result.sections, hasLength(2));
      expect(result.sections[0].id, 'intro');
      expect(result.sections[0].title, '1. Introduction');
      expect(result.sections[0].content, '**Bold** text with *italic*');
      expect(result.sections[1].id, 'usage');
      expect(result.sections[1].title, '2. Usage');
    });

    test('should handle responses with no sections', () async {
      // Arrange
      final mockResponse = MockResponse();
      final minimalJson = {
        'id': 'test-id',
        'version': '1.0',
        'type': 'terms',
        'lang': 'en',
        'sections': [],
      };
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(minimalJson);
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getLegalDocument(tType, tLang);

      // Assert
      expect(result.sections, isEmpty);
    });

    test('should be called with caching policy enabled', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tLegalDocumentJson);
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.getLegalDocument(tType, tLang);

      // Assert
      // Verify that get was called with options parameter (caching policy)
      verify(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // checkEmailExists
  // ---------------------------------------------------------------------------
  group('AuthRemoteDataSourceImpl - checkEmailExists', () {
    test('returns true when email exists (200)', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn({'exists': true});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.checkEmailExists('test@example.com');

      expect(result, isTrue);
    });

    test('returns false when email does not exist (201)', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);
      when(() => r.data).thenReturn({'exists': false});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.checkEmailExists('new@example.com');

      expect(result, isFalse);
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      expect(
        () => dataSource.checkEmailExists('test@example.com'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getTermsInfo
  // ---------------------------------------------------------------------------
  group('AuthRemoteDataSourceImpl - getTermsInfo', () {
    test('returns requiredVersion on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn({'requiredVersion': '2.0'});
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      final result = await dataSource.getTermsInfo();

      expect(result, '2.0');
    });

    test('returns 1.0 when requiredVersion is null', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(<String, dynamic>{});
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      final result = await dataSource.getTermsInfo();

      expect(result, '1.0');
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      expect(() => dataSource.getTermsInfo(), throwsA(isA<ServerException>()));
    });
  });

  // ---------------------------------------------------------------------------
  // acceptTerms
  // ---------------------------------------------------------------------------
  group('AuthRemoteDataSourceImpl - acceptTerms', () {
    test('completes on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      await expectLater(dataSource.acceptTerms('2.0'), completes);
    });

    test('completes on 201', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      await expectLater(dataSource.acceptTerms('2.0'), completes);
    });

    test('throws ServerException on non-200/201 status', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(400);
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      expect(
        () => dataSource.acceptTerms('2.0'),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      expect(
        () => dataSource.acceptTerms('2.0'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // createProfile
  // ---------------------------------------------------------------------------
  group('AuthRemoteDataSourceImpl - createProfile', () {
    test('completes successfully', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      await expectLater(dataSource.createProfile('Ana', 'López'), completes);
    });

    test('posts correct data', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);

      Map<String, dynamic>? captured;
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer((
        inv,
      ) async {
        captured =
            inv.namedArguments[const Symbol('data')] as Map<String, dynamic>;
        return r;
      });

      await dataSource.createProfile('Ana', 'López');

      expect(captured!['first_name'], 'Ana');
      expect(captured!['last_name'], 'López');
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      expect(
        () => dataSource.createProfile('Ana', 'López'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // checkUserStatus
  // ---------------------------------------------------------------------------
  group('AuthRemoteDataSourceImpl - checkUserStatus', () {
    test('completes successfully on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      await expectLater(dataSource.checkUserStatus(), completes);
    });

    test(
      'throws ServerException on DioException with error code in body',
      () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 403,
              data: {'code': 'terms_not_accepted'},
            ),
          ),
        );

        expect(
          () => dataSource.checkUserStatus(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.code,
              'code',
              'terms_not_accepted',
            ),
          ),
        );
      },
    );

    test('throws ServerException on DioException without body', () async {
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      expect(
        () => dataSource.checkUserStatus(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
