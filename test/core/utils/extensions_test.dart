// test/core/utils/extensions_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/l10n/app_localizations.dart';

// Mock AppLocalizations for testing
class MockAppLocalizations implements AppLocalizations {
  String get locale => 'en';

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DateTimeExtensions', () {
    test('toFormattedDate formats date as dd/MM/yyyy', () {
      final date = DateTime(2024, 3, 15);
      expect(date.toFormattedDate(), '15/03/2024');
    });

    test('toFormattedDate handles single digit day and month', () {
      final date = DateTime(2024, 1, 5);
      expect(date.toFormattedDate(), '05/01/2024');
    });

    test('toFormattedDate handles different years', () {
      final date1 = DateTime(2020, 12, 31);
      final date2 = DateTime(2099, 1, 1);

      expect(date1.toFormattedDate(), '31/12/2020');
      expect(date2.toFormattedDate(), '01/01/2099');
    });

    test('toFormattedTime formats time as HH:mm', () {
      final time = DateTime(2024, 1, 1, 14, 30);
      expect(time.toFormattedTime(), '14:30');
    });

    test('toFormattedTime handles morning hours', () {
      final time = DateTime(2024, 1, 1, 9, 5);
      expect(time.toFormattedTime(), '09:05');
    });

    test('toFormattedTime handles midnight', () {
      final time = DateTime(2024, 1, 1, 0, 0);
      expect(time.toFormattedTime(), '00:00');
    });

    test('toFormattedTime handles 23:59', () {
      final time = DateTime(2024, 1, 1, 23, 59);
      expect(time.toFormattedTime(), '23:59');
    });

    test('toFormattedDateTime combines date and time', () {
      final datetime = DateTime(2024, 3, 15, 14, 30);
      expect(datetime.toFormattedDateTime(), '15/03/2024 14:30');
    });

    test('toFormattedDateTime handles edge cases', () {
      final dt1 = DateTime(2099, 12, 31, 23, 59);
      expect(dt1.toFormattedDateTime(), '31/12/2099 23:59');

      final dt2 = DateTime(2000, 1, 1, 0, 0);
      expect(dt2.toFormattedDateTime(), '01/01/2000 00:00');
    });

    test('isToday returns true for today', () {
      final now = DateTime.now();
      expect(now.isToday(), true);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday(), false);
    });

    test('isToday returns false for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(tomorrow.isToday(), false);
    });

    test('isToday returns true regardless of time of day', () {
      final morning = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        8,
        0,
      );
      final evening = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        20,
        0,
      );

      expect(morning.isToday(), true);
      expect(evening.isToday(), true);
    });

    test('isTomorrow returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(tomorrow.isTomorrow(), true);
    });

    test('isTomorrow returns false for today', () {
      final now = DateTime.now();
      expect(now.isTomorrow(), false);
    });

    test('isTomorrow returns false for other days', () {
      final dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));
      expect(dayAfterTomorrow.isTomorrow(), false);

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isTomorrow(), false);
    });

    test('isTomorrow returns true regardless of time of day', () {
      final now = DateTime.now();
      final tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 8, 0);
      final tomorrowEvening = DateTime(now.year, now.month, now.day + 1, 20, 0);

      expect(tomorrowMorning.isTomorrow(), true);
      expect(tomorrowEvening.isTomorrow(), true);
    });
  });

  group('StringExtensions', () {
    group('isValidEmail', () {
      test('returns true for valid email', () {
        expect('user@example.com'.isValidEmail, true);
        expect('test.email@company.code'.isValidEmail, true);
        expect('user@test.com'.isValidEmail, true);
      });

      test('returns false for invalid email', () {
        expect('notanemail'.isValidEmail, false);
        expect('@example.com'.isValidEmail, false);
        expect('user@'.isValidEmail, false);
        expect('@'.isValidEmail, false);
        expect(''.isValidEmail, false);
      });

      test('returns false for empty string', () {
        expect(''.isValidEmail, false);
      });

      test('handles edge cases', () {
        expect('a@b.co'.isValidEmail, true);
        expect('one-two@test-mail.info'.isValidEmail, true);
      });
    });

    group('capitalize', () {
      test('capitalizes first letter and lowercases rest', () {
        expect('hello'.capitalize(), 'Hello');
        expect('HELLO'.capitalize(), 'Hello');
        expect('hELLO'.capitalize(), 'Hello');
      });

      test('returns empty string unchanged', () {
        expect(''.capitalize(), '');
      });

      test('handles single character', () {
        expect('a'.capitalize(), 'A');
        expect('Z'.capitalize(), 'Z');
      });

      test('handles strings with special characters', () {
        expect('hello world'.capitalize(), 'Hello world');
        expect('123abc'.capitalize(), '123abc');
      });

      test('handles already capitalized string', () {
        expect('Hello'.capitalize(), 'Hello');
      });
    });

    group('truncate', () {
      test('returns string unchanged if shorter than maxLength', () {
        expect('hello'.truncate(10), 'hello');
        expect('hello'.truncate(5), 'hello');
      });

      test('truncates string longer than maxLength with default ellipsis', () {
        expect('hello world'.truncate(5), 'hello...');
        expect('abcdefghij'.truncate(3), 'abc...');
      });

      test('truncates with custom ellipsis', () {
        expect('hello world'.truncate(5, ellipsis: '...'), 'hello...');
        expect('hello world'.truncate(5, ellipsis: '→'), 'hello→');
        expect('hello world'.truncate(5, ellipsis: ''), 'hello');
      });

      test('handles edge cases', () {
        expect(''.truncate(5), '');
        expect('a'.truncate(1), 'a');
        expect('ab'.truncate(1), 'a...');
      });

      test('handles maxLength of 0', () {
        expect('hello'.truncate(0), '...');
      });

      test('handles very long strings', () {
        final longStr = 'a' * 1000;
        expect(longStr.truncate(10), 'aaaaaaaaaa...');
        expect(longStr.truncate(10).length, 13); // 10 + '...'
      });
    });
  });

  group('ContextExtensions', () {
    // Context extensions are mainly wrappers around Flutter APIs.
    // Full integration testing requires MaterialApp and widget tree setup.
    // Unit tests are impractical for most context-extension methods.
    // These are validated by: (1) type-safe at compile-time, (2) integration tests,
    // (3) production use in app pages/widgets
  });
}
