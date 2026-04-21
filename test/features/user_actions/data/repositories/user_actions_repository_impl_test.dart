// test/features/user_actions/data/repositories/user_actions_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/user_actions/data/datasources/user_actions_remote_data_source.dart';
import 'package:wap_app/features/user_actions/data/repositories/user_actions_repository_impl.dart';

class MockUserActionsDs extends Mock implements UserActionsRemoteDataSource {}

final tServerException = ServerException(message: 'Server error');
final tNetworkException = NetworkException(message: 'No internet');

void main() {
  late UserActionsRepositoryImpl repo;
  late MockUserActionsDs mockDs;

  setUp(() {
    mockDs = MockUserActionsDs();
    repo = UserActionsRepositoryImpl(remoteDataSource: mockDs);
  });

  tearDown(() {
    resetMocktailState();
  });

  // ── helper that tests a void method's success + all 3 exception branches ──
  void testVoidMethod({
    required String name,
    required Future<void> Function() dsSetup,
    required Future<Either<Failure, void>> Function() call,
  }) {
    group(name, () {
      test('returns Right(null) on success', () async {
        when(dsSetup).thenAnswer((_) async {});
        expect(await call(), const Right(null));
      });

      test('returns Left(ServerFailure) on ServerException', () async {
        when(dsSetup).thenThrow(tServerException);
        final result = await call();
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(dsSetup).thenThrow(tNetworkException);
        final result = await call();
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('expected Left'),
        );
      });

      test('returns Left(UnknownFailure) on unexpected exception', () async {
        when(dsSetup).thenThrow(Exception('Boom'));
        final result = await call();
        result.fold(
          (f) => expect(f, isA<UnknownFailure>()),
          (_) => fail('expected Left'),
        );
      });
    });
  }

  testVoidMethod(
    name: 'addEventToFavorites',
    dsSetup: () => mockDs.addEventToFavorites('e1'),
    call: () => repo.addEventToFavorites('e1'),
  );

  testVoidMethod(
    name: 'removeEventFromFavorites',
    dsSetup: () => mockDs.removeEventFromFavorites('e1'),
    call: () => repo.removeEventFromFavorites('e1'),
  );

  testVoidMethod(
    name: 'followPromoter',
    dsSetup: () => mockDs.followPromoter('p1'),
    call: () => repo.followPromoter('p1'),
  );

  testVoidMethod(
    name: 'unfollowPromoter',
    dsSetup: () => mockDs.unfollowPromoter('p1'),
    call: () => repo.unfollowPromoter('p1'),
  );

  testVoidMethod(
    name: 'blockUser',
    dsSetup: () => mockDs.blockUser('u1'),
    call: () => repo.blockUser('u1'),
  );

  testVoidMethod(
    name: 'unblockUser',
    dsSetup: () => mockDs.unblockUser('u1'),
    call: () => repo.unblockUser('u1'),
  );

  // ── getBlockedUsers ────────────────────────────────────────────────────────
  group('getBlockedUsers', () {
    test('returns Right(ids) on success', () async {
      when(
        () => mockDs.getBlockedUsers(),
      ).thenAnswer((_) async => ['u1', 'u2']);
      final result = await repo.getBlockedUsers();
      expect(
        result,
        isA<Right<Failure, List<String>>>().having(
          (r) => r.fold((l) => null, (r) => r),
          'value',
          ['u1', 'u2'],
        ),
      );
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => mockDs.getBlockedUsers()).thenThrow(tServerException);
      final result = await repo.getBlockedUsers();
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(() => mockDs.getBlockedUsers()).thenThrow(tNetworkException);
      final result = await repo.getBlockedUsers();
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(UnknownFailure) on unexpected exception', () async {
      when(() => mockDs.getBlockedUsers()).thenThrow(Exception('boom'));
      final result = await repo.getBlockedUsers();
      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
