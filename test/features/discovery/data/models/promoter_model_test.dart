// test/features/discovery/data/models/promoter_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/features/discovery/data/models/promoter_model.dart';
import 'package:wap_app/features/discovery/domain/entities/promoter_entity.dart';

void main() {
  group('PromoterModel.fromJson', () {
    final baseJson = <String, dynamic>{
      'id': 99, // int to test toString
      'email': 'promoter@test.com',
      'role': 'promoter',
      'followers_count': 250,
      'events_count': 12,
      'profile': <String, dynamic>{
        'user_id': '99',
        'first_name': 'Alice',
        'last_name': 'Wonder',
        'display_name': 'AliceW',
        'bio': 'Organizer',
        'avatar_url': 'https://cdn.example.com/alice.jpg',
        'company_name': null,
        'website_url': null,
        'city': 'Barcelona',
        'country': 'Spain',
      },
    };

    test('parses scalar fields', () {
      final model = PromoterModel.fromJson(baseJson);

      expect(model.id, '99'); // int to String
      expect(model.email, 'promoter@test.com');
      expect(model.role, 'promoter');
      expect(model.followersCount, 250);
      expect(model.eventsCount, 12);
    });

    test('parses nested profile', () {
      final model = PromoterModel.fromJson(baseJson);
      final profile = model.profile as PromoterProfileModel;

      expect(profile.userId, '99');
      expect(profile.firstName, 'Alice');
      expect(profile.lastName, 'Wonder');
      expect(profile.displayName, 'AliceW');
      expect(profile.city, 'Barcelona');
    });

    test('is a PromoterEntity subtype', () {
      final model = PromoterModel.fromJson(baseJson);
      expect(model, isA<PromoterEntity>());
    });

    test('toJson() round-trips id, email and counts', () {
      final model = PromoterModel.fromJson(baseJson);
      final json = model.toJson();

      expect(json['id'], '99');
      expect(json['email'], 'promoter@test.com');
      expect(json['followers_count'], 250);
      expect(json['events_count'], 12);
    });
  });

  // ── PromoterProfileModel ───────────────────────────────────────────────────
  group('PromoterProfileModel.fromJson', () {
    final json = <String, dynamic>{
      'user_id': 7,
      'first_name': 'Bob',
      'last_name': 'Builder',
      'display_name': 'Bobby',
      'bio': 'We can do it',
      'avatar_url': 'https://cdn.example.com/bob.jpg',
      'company_name': 'Build Co.',
      'website_url': 'https://build.co',
      'city': 'Madrid',
      'country': 'Spain',
    };

    test('parses all fields', () {
      final model = PromoterProfileModel.fromJson(json);

      expect(model.userId, '7');
      expect(model.firstName, 'Bob');
      expect(model.companyName, 'Build Co.');
      expect(model.websiteUrl, 'https://build.co');
    });

    test('optional fields are null when absent', () {
      final minimal = <String, dynamic>{'user_id': '1'};
      final model = PromoterProfileModel.fromJson(minimal);

      expect(model.firstName, isNull);
      expect(model.avatarUrl, isNull);
      expect(model.city, isNull);
    });

    test('toJson() round-trips correctly', () {
      final model = PromoterProfileModel.fromJson(json);
      final out = model.toJson();

      expect(out['user_id'], '7');
      expect(out['first_name'], 'Bob');
      expect(out['company_name'], 'Build Co.');
    });
  });
}
