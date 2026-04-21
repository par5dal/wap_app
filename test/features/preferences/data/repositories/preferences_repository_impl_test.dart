// test/features/preferences/data/repositories/preferences_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/preferences/data/datasources/preferences_remote_data_source.dart';
import 'package:wap_app/features/preferences/data/repositories/preferences_repository_impl.dart';
import 'package:wap_app/features/preferences/domain/entities/user_preferences.dart';

class MockPreferencesDs extends Mock implements PreferencesRemoteDataSource {}

const tPrefs = UserPreferences(lang: 'es');
final tServerException = ServerException(message: 'Server error');
final tNetworkException = NetworkException(message: 'No internet');

void main() {
  late PreferencesRepositoryImpl repo;
  late MockPreferencesDs mockDs;

  setUp(() {
    mockDs = MockPreferencesDs();
    repo = PreferencesRepositoryImpl(remoteDataSource: mockDs);
  });

  // ── getPreferences ─────────────────────────────────────────────────────────
  group('getPreferences', () {
    test('returns Right(prefs) on success', () async {
      when(() => mockDs.getPreferences()).thenAnswer((_) async => tPrefs);
      expect(await repo.getPreferences(), const Right(tPrefs));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => mockDs.getPreferences()).thenThrow(tServerException);
      final result = await repo.getPreferences();
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(() => mockDs.getPreferences()).thenThrow(tNetworkException);
      final result = await repo.getPreferences();
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(UnknownFailure) on unexpected exception', () async {
      when(() => mockDs.getPreferences()).thenThrow(Exception('Boom'));
      final result = await repo.getPreferences();
      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── updatePreferences ──────────────────────────────────────────────────────
  group('updatePreferences', () {
    test('returns Right(prefs) on success', () async {
      when(
        () => mockDs.updatePreferences(lang: 'en'),
      ).thenAnswer((_) async => const UserPreferences(lang: 'en'));
      final result = await repo.updatePreferences(lang: 'en');
      expect(result, const Right(UserPreferences(lang: 'en')));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => mockDs.updatePreferences(lang: any(named: 'lang')),
      ).thenThrow(tServerException);
      final result = await repo.updatePreferences(lang: 'en');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(
        () => mockDs.updatePreferences(lang: any(named: 'lang')),
      ).thenThrow(tNetworkException);
      final result = await repo.updatePreferences(lang: 'en');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(UnknownFailure) on unexpected exception', () async {
      when(
        () => mockDs.updatePreferences(lang: any(named: 'lang')),
      ).thenThrow(Exception('Boom'));
      final result = await repo.updatePreferences(lang: 'en');
      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
