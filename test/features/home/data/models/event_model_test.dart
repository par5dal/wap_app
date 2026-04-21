// test/features/home/data/models/event_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';

void main() {
  group('EventModel.fromJson', () {
    // ── Clustering format ────────────────────────────────────────────────────
    // Detected when json has 'latitude' + 'longitude' but NO 'venue' key.
    group('clustering format', () {
      final baseJson = <String, dynamic>{
        'id': 'event-1',
        'title': 'Test Event',
        'description': 'A description',
        'slug': 'test-event',
        'start_datetime': '2026-06-15T20:00:00.000Z',
        'end_datetime': '2026-06-15T23:00:00.000Z',
        'price': '10',
        'currency': 'EUR',
        'status': 'published',
        'latitude': 40.4168,
        'longitude': -3.7038,
        'venue_name': 'Some Venue',
        'primary_category_id': 1, // intentionally int to test toString
        'primary_category_name': 'Music',
        'primary_category_slug': 'music',
        'primary_category_icon': '<svg/>',
        'secondary_categories': <dynamic>[
          <String, dynamic>{
            'id': '2',
            'name': 'Arts',
            'slug': 'arts',
            'svg': null,
          },
        ],
        'primary_image_url': 'https://example.com/img.jpg',
        'promoter_id': 'promoter-1',
        'is_favorite': true,
      };

      test('parses scalar fields', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.id, 'event-1');
        expect(model.title, 'Test Event');
        expect(model.description, 'A description');
        expect(model.slug, 'test-event');
        expect(model.price, '10');
        expect(model.currency, 'EUR');
        expect(model.status, 'published');
        expect(model.isFavorite, isTrue);
        expect(model.promoterDirectId, 'promoter-1');
      });

      test('parses start and end datetime', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.startDatetime, DateTime.parse('2026-06-15T20:00:00.000Z'));
        expect(model.endDatetime, DateTime.parse('2026-06-15T23:00:00.000Z'));
      });

      test('builds venue from lat/lon fields', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.venue.name, 'Some Venue');
        expect(model.venue.location.type, 'Point');
        // coordinates are [longitude, latitude]
        expect(model.venue.location.coordinates[0], -3.7038);
        expect(model.venue.location.coordinates[1], 40.4168);
      });

      test('builds primary category from flat fields', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.category, isNotNull);
        expect(model.category!.id, '1'); // int coerced to String
        expect(model.category!.name, 'Music');
        expect(model.category!.slug, 'music');
        expect(model.category!.svg, '<svg/>');
      });

      test('builds categories list with primary + secondary', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.categories, isNotNull);
        expect(model.categories!.length, 2);
        expect(model.categories![0].slug, 'music');
        expect(model.categories![1].slug, 'arts');
      });

      test('creates single image from primary_image_url', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.images, isNotNull);
        expect(model.images!.length, 1);
        expect(model.images![0].url, 'https://example.com/img.jpg');
        expect(model.images![0].isPrimary, isTrue);
      });

      test('images is null when primary_image_url is absent', () {
        final json = Map<String, dynamic>.from(baseJson)
          ..remove('primary_image_url');
        final model = EventModel.fromJson(json);

        expect(model.images, isNull);
      });

      test('is_favorite defaults to false when absent', () {
        final json = Map<String, dynamic>.from(baseJson)..remove('is_favorite');
        final model = EventModel.fromJson(json);

        expect(model.isFavorite, isFalse);
      });

      test(
        'category and categories are null when primary_category_slug absent',
        () {
          final json = Map<String, dynamic>.from(baseJson)
            ..remove('primary_category_slug')
            ..remove('secondary_categories');
          final model = EventModel.fromJson(json);

          expect(model.category, isNull);
          expect(model.categories, isNull);
        },
      );

      test(
        'categories contains only primary when secondary_categories absent',
        () {
          final json = Map<String, dynamic>.from(baseJson)
            ..remove('secondary_categories');
          final model = EventModel.fromJson(json);

          expect(model.categories!.length, 1);
          expect(model.categories![0].slug, 'music');
        },
      );

      test('end_datetime is null when absent', () {
        final json = Map<String, dynamic>.from(baseJson)
          ..remove('end_datetime');
        final model = EventModel.fromJson(json);

        expect(model.endDatetime, isNull);
      });
    });

    // ── Full format ──────────────────────────────────────────────────────────
    // Standard endpoint response: has 'venue' key as object.
    group('full format with categories array', () {
      final venueJson = <String, dynamic>{
        'id': 'venue-1',
        'name': 'Concert Hall',
        'address': '123 Main St',
        'location': <String, dynamic>{
          'type': 'Point',
          'coordinates': <double>[-3.7038, 40.4168],
        },
      };

      final baseJson = <String, dynamic>{
        'id': 'event-2',
        'title': 'Full Format Event',
        'start_datetime': '2026-07-01T19:00:00.000Z',
        'venue': venueJson,
        'categories': <dynamic>[
          <String, dynamic>{'id': '1', 'name': 'Music', 'slug': 'music'},
          <String, dynamic>{'id': '2', 'name': 'Arts', 'slug': 'arts'},
        ],
        'images': <dynamic>[
          <String, dynamic>{
            'id': 'img-1',
            'url': 'https://example.com/1.jpg',
            'is_primary': true,
          },
        ],
        'moderation_status': 'approved',
        'moderation_comment': 'Looks good',
        'moderated_at': '2026-06-01T12:00:00.000Z',
        'is_favorite': false,
      };

      test('parses id, title and venue', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.id, 'event-2');
        expect(model.title, 'Full Format Event');
        expect(model.venue.id, 'venue-1');
        expect(model.venue.name, 'Concert Hall');
      });

      test('parses categories array — first becomes primary', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.categories!.length, 2);
        expect(model.category!.slug, 'music');
        expect(model.categories![1].slug, 'arts');
      });

      test('parses images array', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.images!.length, 1);
        expect(model.images![0].id, 'img-1');
        expect(model.images![0].isPrimary, isTrue);
      });

      test('parses moderation fields', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.moderationStatus, 'approved');
        expect(model.moderationComment, 'Looks good');
        expect(model.moderatedAt, DateTime.parse('2026-06-01T12:00:00.000Z'));
      });

      test(
        'category and categories are null when categories is empty list',
        () {
          final json = Map<String, dynamic>.from(baseJson)
            ..['categories'] = <dynamic>[];
          final model = EventModel.fromJson(json);

          expect(model.category, isNull);
          expect(model.categories, isNull);
        },
      );

      test('images is null when images key is absent', () {
        final json = Map<String, dynamic>.from(baseJson)..remove('images');
        final model = EventModel.fromJson(json);

        expect(model.images, isNull);
      });

      test('is_favorite defaults to false', () {
        final model = EventModel.fromJson(baseJson);
        expect(model.isFavorite, isFalse);
      });
    });

    // ── Full format — singular category fallback ─────────────────────────────
    group('full format with singular category fallback', () {
      final venueJson = <String, dynamic>{
        'id': 'v1',
        'name': 'Bar',
        'address': 'Calle Falsa 123',
        'location': <String, dynamic>{
          'type': 'Point',
          'coordinates': <double>[-3.7038, 40.4168],
        },
      };

      final baseJson = <String, dynamic>{
        'id': 'event-3',
        'title': 'Legacy Event',
        'start_datetime': '2026-08-01T21:00:00.000Z',
        'venue': venueJson,
        'category': <String, dynamic>{
          'id': '3',
          'name': 'Dance',
          'slug': 'dance',
        },
      };

      test('parses singular category as fallback', () {
        final model = EventModel.fromJson(baseJson);

        expect(model.category, isNotNull);
        expect(model.category!.slug, 'dance');
        expect(model.categories!.length, 1);
        expect(model.categories![0].slug, 'dance');
      });

      test(
        'both category and categories are null when neither key present',
        () {
          final json = Map<String, dynamic>.from(baseJson)..remove('category');
          final model = EventModel.fromJson(json);

          expect(model.category, isNull);
          expect(model.categories, isNull);
        },
      );
    });
  });
}
