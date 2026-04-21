// test/features/promoter_profile/data/models/promoter_profile_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/features/promoter_profile/data/models/promoter_profile_model.dart';
import 'package:wap_app/features/promoter_profile/domain/entities/promoter_profile.dart';

void main() {
  group('PromoterProfileModel', () {
    final baseJson = <String, dynamic>{
      'id': '123',
      'email': 'org@test.com',
      'role': 'promoter',
      'profile': <String, dynamic>{
        'user_id': '123',
        'first_name': 'Carlos',
        'last_name': 'García',
        'display_name': 'CarlosG',
        'bio': 'Event organizer',
        'avatar_url': 'https://cdn.example.com/carlos.jpg',
        'company_name': 'EventoCo',
        'website_url': 'https://evento.co',
        'city': 'Seville',
        'country': 'Spain',
      },
      'followers_count': 500,
      'events_count': 30,
      'is_following': true,
    };

    group('fromJson', () {
      test('parses scalar fields', () {
        final model = PromoterProfileModel.fromJson(baseJson);

        expect(model.id, '123');
        expect(model.email, 'org@test.com');
        expect(model.role, 'promoter');
        expect(model.followersCount, 500);
        expect(model.eventsCount, 30);
        expect(model.isFollowing, isTrue);
      });

      test('parses nested profile', () {
        final model = PromoterProfileModel.fromJson(baseJson);
        expect(model.profile, isNotNull);
        expect(model.profile!.firstName, 'Carlos');
        expect(model.profile!.companyName, 'EventoCo');
        expect(model.profile!.city, 'Seville');
      });

      test('profile is null when profile key is absent', () {
        final json = Map<String, dynamic>.from(baseJson)..remove('profile');
        final model = PromoterProfileModel.fromJson(json);
        expect(model.profile, isNull);
      });

      test('defaults: followersCount=0, eventsCount=0, isFollowing=false', () {
        final json = <String, dynamic>{'id': '1', 'email': 'x@x.com'};
        final model = PromoterProfileModel.fromJson(json);

        expect(model.followersCount, 0);
        expect(model.eventsCount, 0);
        expect(model.isFollowing, isFalse);
      });

      test('id coerces int to String', () {
        final json = Map<String, dynamic>.from(baseJson)..['id'] = 456;
        final model = PromoterProfileModel.fromJson(json);
        expect(model.id, '456');
      });
    });

    group('toEntity()', () {
      test('returns PromoterProfile with matching fields', () {
        final model = PromoterProfileModel.fromJson(baseJson);
        final entity = model.toEntity();

        expect(entity, isA<PromoterProfile>());
        expect(entity.id, '123');
        expect(entity.email, 'org@test.com');
        expect(entity.followersCount, 500);
        expect(entity.isFollowing, isTrue);
      });

      test('maps nested profile fields to PromoterProfile', () {
        final model = PromoterProfileModel.fromJson(baseJson);
        final entity = model.toEntity();

        expect(entity.firstName, 'Carlos');
        expect(entity.companyName, 'EventoCo');
        expect(entity.city, 'Seville');
      });
    });
  });
}
