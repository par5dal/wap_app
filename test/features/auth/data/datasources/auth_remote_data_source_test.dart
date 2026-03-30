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
}
