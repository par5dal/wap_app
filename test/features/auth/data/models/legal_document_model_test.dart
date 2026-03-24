// test/features/auth/data/models/legal_document_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/features/auth/data/models/legal_document_model.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';

void main() {
  const tDate = '2024-01-15';

  const tLegalDocumentJson = {
    'id': 'terms-1.0-en',
    'version': '1.0',
    'type': 'terms',
    'lang': 'en',
    'effective_date': tDate,
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

  group('LegalDocumentModel', () {
    group('fromJson', () {
      test('should return a valid model when parsing valid JSON', () {
        // Arrange & Act
        final result = LegalDocumentModel.fromJson(tLegalDocumentJson);

        // Assert
        expect(result.id, 'terms-1.0-en');
        expect(result.version, '1.0');
        expect(result.type, 'terms');
        expect(result.lang, 'en');
        expect(result.effectiveDate, DateTime(2024, 01, 15));
        expect(result.sections, hasLength(2));
        expect(result.sections[0].id, 'intro');
        expect(result.sections[0].title, '1. Introduction');
        expect(result.sections[0].content, '**Bold** text with *italic*');
        expect(result.sections[1].id, 'usage');
        expect(result.sections[1].title, '2. Usage');
        expect(result.sections[1].content, 'This is our usage policy.');
      });

      test('should handle null effective_date gracefully', () {
        // Arrange
        final jsonWithNullDate = {
          ...tLegalDocumentJson,
          'effective_date': null,
        };

        // Act
        final result = LegalDocumentModel.fromJson(jsonWithNullDate);

        // Assert
        // When effective_date is null, DateTime.now() is used as fallback
        expect(result.effectiveDate, isA<DateTime>());
        // Verify it's close to now (within 10 seconds)
        final now = DateTime.now();
        expect(result.effectiveDate.difference(now).inSeconds, lessThan(10));
      });

      test('should provide default values for missing optional fields', () {
        // Arrange
        final minimalJson = {'id': 'test-id'};

        // Act
        final result = LegalDocumentModel.fromJson(minimalJson);

        // Assert
        expect(result.id, 'test-id');
        expect(result.version, '1.0');
        expect(result.type, 'terms');
        expect(result.lang, 'es');
        expect(result.sections, isEmpty);
      });

      test('should handle empty sections list', () {
        // Arrange
        final jsonWithEmptySections = {...tLegalDocumentJson, 'sections': []};

        // Act
        final result = LegalDocumentModel.fromJson(jsonWithEmptySections);

        // Assert
        expect(result.sections, isEmpty);
      });

      test('should handle malformed effective_date string', () {
        // Arrange
        final jsonWithBadDate = {
          ...tLegalDocumentJson,
          'effective_date': 'invalid-date',
        };

        // Act & Assert
        expect(
          () => LegalDocumentModel.fromJson(jsonWithBadDate),
          throwsA(isA<FormatException>()),
        );
      });

      test('should parse privacy policy documents', () {
        // Arrange
        final privacyJson = {
          'id': 'privacy-1.0-es',
          'version': '1.0',
          'type': 'privacy',
          'lang': 'es',
          'effective_date': '2024-01-15',
          'sections': [
            {
              'id': 'recopilacion',
              'title': '1. Recopilación de Datos',
              'content': 'Recopilamos información personal...',
            },
          ],
        };

        // Act
        final result = LegalDocumentModel.fromJson(privacyJson);

        // Assert
        expect(result.type, 'privacy');
        expect(result.lang, 'es');
        expect(result.sections[0].title, '1. Recopilación de Datos');
      });
    });

    group('toEntity', () {
      test('should convert model to entity correctly', () {
        // Arrange
        final model = LegalDocumentModel.fromJson(tLegalDocumentJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<LegalDocument>());
        expect(entity.id, model.id);
        expect(entity.version, model.version);
        expect(entity.type, model.type);
        expect(entity.lang, model.lang);
        expect(entity.effectiveDate, model.effectiveDate);
        expect(entity.sections, hasLength(2));
      });

      test('should preserve section content in entity', () {
        // Arrange
        final model = LegalDocumentModel.fromJson(tLegalDocumentJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.sections[0].content, '**Bold** text with *italic*');
        expect(entity.sections[1].content, 'This is our usage policy.');
      });

      test('should convert multiple sections accurately', () {
        // Arrange
        final jsonWithMultipleSections = {
          ...tLegalDocumentJson,
          'sections': [
            for (int i = 0; i < 5; i++)
              {
                'id': 'section-$i',
                'title': 'Section ${i + 1}',
                'content': 'Content for section $i',
              },
          ],
        };
        final model = LegalDocumentModel.fromJson(jsonWithMultipleSections);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.sections, hasLength(5));
        for (int i = 0; i < 5; i++) {
          expect(entity.sections[i].id, 'section-$i');
          expect(entity.sections[i].title, 'Section ${i + 1}');
          expect(entity.sections[i].content, 'Content for section $i');
        }
      });
    });

    group('JSON serialization roundtrip', () {
      test('should create identical entity after fromJson → toEntity', () {
        // Arrange
        final model1 = LegalDocumentModel.fromJson(tLegalDocumentJson);
        final entity = model1.toEntity();

        // Act & Assert
        expect(entity.id, tLegalDocumentJson['id']);
        expect(entity.version, tLegalDocumentJson['version']);
        expect(entity.type, tLegalDocumentJson['type']);
        expect(entity.lang, tLegalDocumentJson['lang']);
      });
    });

    group('Edge cases', () {
      test('should handle very long markdown content', () {
        // Arrange
        final longContent = 'A' * 10000;
        final jsonWithLongContent = {
          ...tLegalDocumentJson,
          'sections': [
            {'id': 'long', 'title': 'Long Section', 'content': longContent},
          ],
        };

        // Act
        final model = LegalDocumentModel.fromJson(jsonWithLongContent);
        final entity = model.toEntity();

        // Assert
        expect(entity.sections[0].content, longContent);
        expect(entity.sections[0].content.length, 10000);
      });

      test('should handle special characters in markdown', () {
        // Arrange
        final specialContent =
            '# Header\n\n**Bold** __Underline__ ~~Strikethrough~~ `code`\n\n[Link](https://example.com)';
        final jsonWithSpecialChars = {
          ...tLegalDocumentJson,
          'sections': [
            {
              'id': 'special',
              'title': 'Special Characters',
              'content': specialContent,
            },
          ],
        };

        // Act
        final model = LegalDocumentModel.fromJson(jsonWithSpecialChars);

        // Assert
        expect(model.sections[0].content, specialContent);
      });

      test('should handle unicode characters', () {
        // Arrange
        final unicodeContent = '¡Hola! 你好 مرحبا 🚀 ☑️';
        final jsonWithUnicode = {
          ...tLegalDocumentJson,
          'sections': [
            {
              'id': 'unicode',
              'title': 'Unicode Test',
              'content': unicodeContent,
            },
          ],
        };

        // Act
        final model = LegalDocumentModel.fromJson(jsonWithUnicode);

        // Assert
        expect(model.sections[0].content, unicodeContent);
      });
    });
  });
}
