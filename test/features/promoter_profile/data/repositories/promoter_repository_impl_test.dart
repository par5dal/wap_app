// test/features/promoter_profile/data/repositories/promoter_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/promoter_profile/data/datasources/promoter_remote_data_source.dart';
import 'package:wap_app/features/promoter_profile/data/models/promoter_profile_model.dart';
import 'package:wap_app/features/promoter_profile/data/repositories/promoter_repository_impl.dart';
import 'package:wap_app/features/promoter_profile/domain/entities/promoter_profile.dart';

class MockPromoterDs extends Mock implements PromoterRemoteDataSource {}

final tServerException = ServerException(message: 'Server error');
final tNetworkException = NetworkException(message: 'No internet');

PromoterProfileModel tPromoterModel() => PromoterProfileModel(
  id: 'p1',
  email: 'promoter@test.com',
  followersCount: 10,
  eventsCount: 5,
  isFollowing: false,
);

void main() {
  late PromoterRepositoryImpl repo;
  late MockPromoterDs mockDs;

  setUp(() {
    mockDs = MockPromoterDs();
    repo = PromoterRepositoryImpl(remoteDataSource: mockDs);
  });

  // ── getPromoterProfile ─────────────────────────────────────────────────────
  group('getPromoterProfile', () {
    test('returns Right(PromoterProfile) on success', () async {
      when(
        () => mockDs.getPromoterProfile('p1'),
      ).thenAnswer((_) async => tPromoterModel());
      final result = await repo.getPromoterProfile('p1');

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (p) {
        expect(p, isA<PromoterProfile>());
        expect(p.id, 'p1');
      });
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => mockDs.getPromoterProfile(any())).thenThrow(tServerException);
      final result = await repo.getPromoterProfile('p1');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(() => mockDs.getPromoterProfile(any())).thenThrow(tNetworkException);
      final result = await repo.getPromoterProfile('p1');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(UnknownFailure) on unexpected exception', () async {
      when(() => mockDs.getPromoterProfile(any())).thenThrow(Exception('boom'));
      final result = await repo.getPromoterProfile('p1');
      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── getPromoterEvents ──────────────────────────────────────────────────────
  group('getPromoterEvents', () {
    test('returns Right(empty list) when datasource returns empty', () async {
      when(
        () => mockDs.getPromoterEvents(
          promoterId: any(named: 'promoterId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      final result = await repo.getPromoterEvents(promoterId: 'p1');
      expect(result, const Right(<dynamic>[]));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => mockDs.getPromoterEvents(
          promoterId: any(named: 'promoterId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(tServerException);

      final result = await repo.getPromoterEvents(promoterId: 'p1');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(
        () => mockDs.getPromoterEvents(
          promoterId: any(named: 'promoterId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(tNetworkException);

      final result = await repo.getPromoterEvents(promoterId: 'p1');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
