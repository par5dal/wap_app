// test/features/profile/data/repositories/profile_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:wap_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';

class MockProfileDs extends Mock implements ProfileRemoteDataSource {}

// ── Helpers ───────────────────────────────────────────────────────────────────

UserWithProfileEntity tUser() => UserWithProfileEntity(
  id: 'u1',
  email: 'test@test.com',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

ProfileEntity tProfile() => ProfileEntity(
  userId: 'u1',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

// NetworkException from app_exception.dart
const tNetworkException = NetworkException(message: 'No internet');
const tServerException = ServerException(message: 'Server error');

void main() {
  late ProfileRepositoryImpl repo;
  late MockProfileDs mockDs;

  setUp(() {
    mockDs = MockProfileDs();
    repo = ProfileRepositoryImpl(remoteDataSource: mockDs);
  });

  // ── getMyProfile ───────────────────────────────────────────────────────────
  group('getMyProfile', () {
    test('returns Right(user) on success', () async {
      when(() => mockDs.getMyProfile()).thenAnswer((_) async => tUser());
      final result = await repo.getMyProfile();
      expect(result, Right(tUser()));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => mockDs.getMyProfile()).thenThrow(tServerException);
      final result = await repo.getMyProfile();
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left on NetworkException', () async {
      when(() => mockDs.getMyProfile()).thenThrow(tNetworkException);
      final result = await repo.getMyProfile();
      result.fold(
        (f) => expect(f, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left on unexpected exception', () async {
      when(() => mockDs.getMyProfile()).thenThrow(Exception('boom'));
      final result = await repo.getMyProfile();
      result.fold(
        (f) => expect(f, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── updateMyProfile ────────────────────────────────────────────────────────
  group('updateMyProfile', () {
    test('returns Right(profile) on success', () async {
      when(
        () => mockDs.updateMyProfile(any()),
      ).thenAnswer((_) async => tProfile());
      final result = await repo.updateMyProfile({'first_name': 'Jane'});
      expect(result, Right(tProfile()));
    });

    test('returns Left on ServerException', () async {
      when(() => mockDs.updateMyProfile(any())).thenThrow(tServerException);
      final result = await repo.updateMyProfile({});
      result.fold(
        (f) => expect(f, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── deleteResource ─────────────────────────────────────────────────────────
  group('deleteResource', () {
    test('returns Right(null) on success', () async {
      when(() => mockDs.deleteResource(any())).thenAnswer((_) async {});
      expect(
        await repo.deleteResource('https://cdn.example.com/img.jpg'),
        const Right(null),
      );
    });

    test('returns Left on exception', () async {
      when(() => mockDs.deleteResource(any())).thenThrow(tServerException);
      final result = await repo.deleteResource('url');
      result.fold(
        (f) => expect(f, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── getUploadSignature ─────────────────────────────────────────────────────
  group('getUploadSignature', () {
    test('returns Right(map) on success', () async {
      when(
        () => mockDs.getUploadSignature(
          preset: any(named: 'preset'),
          uploadType: any(named: 'uploadType'),
        ),
      ).thenAnswer((_) async => {'signature': 'abc123'});

      final result = await repo.getUploadSignature(
        preset: 'wap_avatars',
        uploadType: 'avatar',
      );
      result.fold(
        (_) => fail('expected Right'),
        (map) => expect(map, {'signature': 'abc123'}),
      );
    });

    test('returns Left on exception', () async {
      when(
        () => mockDs.getUploadSignature(
          preset: any(named: 'preset'),
          uploadType: any(named: 'uploadType'),
        ),
      ).thenThrow(tServerException);

      final result = await repo.getUploadSignature(
        preset: 'wap_avatars',
        uploadType: 'avatar',
      );
      result.fold(
        (f) => expect(f, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
