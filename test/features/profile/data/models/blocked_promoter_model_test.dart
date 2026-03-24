// test/features/profile/data/models/blocked_promoter_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/features/profile/data/models/blocked_promoter_model.dart';
import 'package:wap_app/features/profile/domain/entities/blocked_promoter.dart';

void main() {
  group('BlockedPromoterModel.fromJson', () {
    final tJson = {
      'blockId': 'block-abc',
      'blockedAt': '2024-01-15T10:00:00Z',
      'user': {
        'id': 'user-123',
        'email': 'carlos@test.com',
        'profile': {
          'first_name': 'Carlos',
          'last_name': 'López',
          'display_name': 'Carlos Events',
          'avatar_url': 'https://example.com/avatar.jpg',
          'bio': 'Event organizer',
        },
      },
    };

    test('parses id from nested user field', () {
      final model = BlockedPromoterModel.fromJson(tJson);
      expect(model.id, 'user-123');
    });

    test('parses email from nested user field', () {
      final model = BlockedPromoterModel.fromJson(tJson);
      expect(model.email, 'carlos@test.com');
    });

    test('parses profile from nested user.profile field', () {
      final model = BlockedPromoterModel.fromJson(tJson);
      expect(model.profile?['display_name'], 'Carlos Events');
    });

    test('handles missing profile gracefully', () {
      final jsonNoProfile = {
        'blockId': 'block-xyz',
        'blockedAt': '2024-01-15T10:00:00Z',
        'user': {'id': 'user-456', 'email': 'noprofile@test.com'},
      };
      final model = BlockedPromoterModel.fromJson(jsonNoProfile);
      expect(model.id, 'user-456');
      expect(model.profile, isNull);
    });

    test('handles missing user gracefully with empty defaults', () {
      final jsonNoUser = {'blockId': 'block-xyz', 'blockedAt': '2024-01-15'};
      final model = BlockedPromoterModel.fromJson(jsonNoUser);
      expect(model.id, '');
      expect(model.email, '');
    });
  });

  group('BlockedPromoterModel.toEntity', () {
    test('converts to BlockedPromoter entity with all fields', () {
      final model = BlockedPromoterModel(
        id: 'user-123',
        email: 'carlos@test.com',
        profile: {
          'first_name': 'Carlos',
          'last_name': 'López',
          'display_name': 'Carlos Events',
          'avatar_url': 'https://example.com/avatar.jpg',
          'bio': 'Event organizer',
        },
      );

      final entity = model.toEntity();

      expect(entity, isA<BlockedPromoter>());
      expect(entity.id, 'user-123');
      expect(entity.email, 'carlos@test.com');
      expect(entity.displayName, 'Carlos Events');
      expect(entity.firstName, 'Carlos');
      expect(entity.lastName, 'López');
      expect(entity.avatarUrl, 'https://example.com/avatar.jpg');
      expect(entity.bio, 'Event organizer');
    });

    test('fullName uses displayName when set', () {
      final model = BlockedPromoterModel(
        id: 'u1',
        email: 'test@test.com',
        profile: {
          'first_name': 'Carlos',
          'last_name': 'López',
          'display_name': 'Carlos Events',
        },
      );
      expect(model.toEntity().fullName, 'Carlos Events');
    });

    test('fullName falls back to firstName + lastName', () {
      final model = BlockedPromoterModel(
        id: 'u1',
        email: 'test@test.com',
        profile: {
          'first_name': 'Carlos',
          'last_name': 'López',
          'display_name': '',
        },
      );
      expect(model.toEntity().fullName, 'Carlos López');
    });

    test('converts to entity with null profile fields', () {
      final model = BlockedPromoterModel(
        id: 'user-456',
        email: 'noprofile@test.com',
        profile: null,
      );
      final entity = model.toEntity();
      expect(entity.displayName, isNull);
      expect(entity.firstName, '');
      expect(entity.lastName, '');
      expect(entity.avatarUrl, isNull);
    });
  });
}
