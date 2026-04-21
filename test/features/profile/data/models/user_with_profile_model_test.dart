// test/features/profile/data/models/user_with_profile_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/features/profile/data/models/user_with_profile_model.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';

void main() {
  group('UserWithProfileModel.fromJson', () {
    final baseJson = <String, dynamic>{
      'id': 'user-123',
      'email': 'john@example.com',
      'role': 'user',
      'is_active': true,
      'created_at': '2024-01-01T00:00:00.000Z',
      'updated_at': '2024-06-01T00:00:00.000Z',
      'profile': null,
    };

    test('parses scalar fields', () {
      final model = UserWithProfileModel.fromJson(baseJson);

      expect(model.id, 'user-123');
      expect(model.email, 'john@example.com');
      expect(model.role, 'user');
      expect(model.isActive, isTrue);
      expect(model.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(model.updatedAt, DateTime.parse('2024-06-01T00:00:00.000Z'));
    });

    test('profile is null when profile key is null', () {
      final model = UserWithProfileModel.fromJson(baseJson);
      expect(model.profile, isNull);
    });

    test('parses nested profile when present', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..['profile'] = <String, dynamic>{
          'user_id': 'user-123',
          'first_name': 'John',
          'last_name': 'Doe',
          'updated_at': '2024-06-01T00:00:00.000Z',
        };
      final model = UserWithProfileModel.fromJson(json);

      expect(model.profile, isNotNull);
      expect(model.profile!.firstName, 'John');
      expect(model.profile!.lastName, 'Doe');
    });

    test('role and isActive are null when absent', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..remove('role')
        ..remove('is_active');
      final model = UserWithProfileModel.fromJson(json);

      expect(model.role, isNull);
      expect(model.isActive, isNull);
    });

    test('toEntity() returns UserWithProfileEntity with same values', () {
      final model = UserWithProfileModel.fromJson(baseJson);
      final entity = model.toEntity();

      expect(entity, isA<UserWithProfileEntity>());
      expect(entity.id, 'user-123');
      expect(entity.email, 'john@example.com');
      expect(entity.profile, isNull);
    });

    test('toJson() round-trips id and email', () {
      final model = UserWithProfileModel.fromJson(baseJson);
      final json = model.toJson();

      expect(json['id'], 'user-123');
      expect(json['email'], 'john@example.com');
    });
  });
}
