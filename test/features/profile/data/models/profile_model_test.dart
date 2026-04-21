// test/features/profile/data/models/profile_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/features/profile/data/models/profile_model.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';

void main() {
  group('ProfileModel.fromJson', () {
    final baseJson = <String, dynamic>{
      'user_id': 42, // intentionally int to test toString
      'display_name': 'JohnD',
      'first_name': 'John',
      'last_name': 'Doe',
      'date_of_birth': '1990-06-15',
      'phone_number': '+34600000000',
      'bio': 'Flutter dev',
      'avatar_url': 'https://cdn.example.com/avatar.jpg',
      'address': 'Calle Falsa 123',
      'city': 'Madrid',
      'country': 'Spain',
      'postal_code': '28001',
      'company_name': 'Acme Events S.L.',
      'tax_id': 'B12345678',
      'website_url': 'https://acmeevents.com',
      'created_at': '2024-01-01T00:00:00.000Z',
      'updated_at': '2024-06-01T00:00:00.000Z',
    };

    test('parses all scalar fields', () {
      final model = ProfileModel.fromJson(baseJson);

      expect(model.userId, '42'); // int coerced to String
      expect(model.displayName, 'JohnD');
      expect(model.firstName, 'John');
      expect(model.lastName, 'Doe');
      expect(model.phoneNumber, '+34600000000');
      expect(model.bio, 'Flutter dev');
      expect(model.avatarUrl, 'https://cdn.example.com/avatar.jpg');
      expect(model.address, 'Calle Falsa 123');
      expect(model.city, 'Madrid');
      expect(model.country, 'Spain');
      expect(model.postalCode, '28001');
    });

    test('parses promoter fields', () {
      final model = ProfileModel.fromJson(baseJson);

      expect(model.companyName, 'Acme Events S.L.');
      expect(model.taxId, 'B12345678');
      expect(model.websiteUrl, 'https://acmeevents.com');
    });

    test('promoter fields are null when absent', () {
      final json = <String, dynamic>{
        'user_id': '1',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };
      final model = ProfileModel.fromJson(json);

      expect(model.companyName, isNull);
      expect(model.taxId, isNull);
      expect(model.websiteUrl, isNull);
    });

    test('parses date_of_birth correctly', () {
      final model = ProfileModel.fromJson(baseJson);
      expect(model.dateOfBirth, DateTime.parse('1990-06-15'));
    });

    test('uses direct created_at when present', () {
      final model = ProfileModel.fromJson(baseJson);
      expect(model.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });

    test('prefers nested user.created_at over direct created_at', () {
      final json = Map<String, dynamic>.from(
        baseJson,
      )..['user'] = <String, dynamic>{'created_at': '2023-01-01T00:00:00.000Z'};
      final model = ProfileModel.fromJson(json);
      expect(model.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
    });

    test('falls back to updated_at when no created_at is present', () {
      final json = Map<String, dynamic>.from(baseJson)..remove('created_at');
      final model = ProfileModel.fromJson(json);
      expect(model.createdAt, model.updatedAt);
    });

    test('date_of_birth is null when absent', () {
      final json = Map<String, dynamic>.from(baseJson)..remove('date_of_birth');
      final model = ProfileModel.fromJson(json);
      expect(model.dateOfBirth, isNull);
    });

    test('optional string fields are null when absent', () {
      final json = <String, dynamic>{
        'user_id': '1',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };
      final model = ProfileModel.fromJson(json);
      expect(model.displayName, isNull);
      expect(model.firstName, isNull);
      expect(model.avatarUrl, isNull);
      expect(model.city, isNull);
    });

    test('toEntity() maps all fields correctly', () {
      final model = ProfileModel.fromJson(baseJson);
      final entity = model.toEntity();

      expect(entity, isA<ProfileEntity>());
      expect(entity.userId, '42');
      expect(entity.firstName, 'John');
      expect(entity.avatarUrl, 'https://cdn.example.com/avatar.jpg');
      expect(entity.city, 'Madrid');
      expect(entity.companyName, 'Acme Events S.L.');
      expect(entity.taxId, 'B12345678');
      expect(entity.websiteUrl, 'https://acmeevents.com');
    });
  });

  group('ProfileModel.toJson', () {
    test('includes promoter fields when present', () {
      final model = ProfileModel.fromJson({
        'user_id': '1',
        'company_name': 'Acme Events S.L.',
        'tax_id': 'B12345678',
        'website_url': 'https://acmeevents.com',
        'updated_at': '2024-01-01T00:00:00.000Z',
      });

      final json = model.toJson();

      expect(json['companyName'], 'Acme Events S.L.');
      expect(json['taxId'], 'B12345678');
      expect(json['websiteUrl'], 'https://acmeevents.com');
    });

    test('promoter fields are null in json when absent', () {
      final model = ProfileModel.fromJson({
        'user_id': '1',
        'updated_at': '2024-01-01T00:00:00.000Z',
      });

      final json = model.toJson();

      expect(json['companyName'], isNull);
      expect(json['taxId'], isNull);
      expect(json['websiteUrl'], isNull);
    });
  });
}
