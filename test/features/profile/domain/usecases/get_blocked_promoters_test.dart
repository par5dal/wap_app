// test/features/profile/domain/usecases/get_blocked_promoters_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/entities/blocked_promoter.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:wap_app/features/profile/domain/usecases/get_blocked_promoters.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

BlockedPromoter makeBlockedPromoter(String id) => BlockedPromoter(
  id: id,
  email: 'promoter$id@test.com',
  firstName: 'Promoter',
  lastName: id,
  displayName: 'Promoter $id',
  avatarUrl: null,
  bio: null,
);

void main() {
  late GetBlockedPromotersUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetBlockedPromotersUseCase(mockRepository);
  });

  test('returns Right(list) when repository succeeds', () async {
    final tPromoters = [makeBlockedPromoter('1'), makeBlockedPromoter('2')];

    when(
      () => mockRepository.getBlockedPromoters(limit: any(named: 'limit')),
    ).thenAnswer((_) async => Right(tPromoters));

    final result = await useCase();

    expect(result, Right(tPromoters));
    verify(() => mockRepository.getBlockedPromoters(limit: 50)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Right(empty list) when no blocked promoters', () async {
    when(
      () => mockRepository.getBlockedPromoters(limit: any(named: 'limit')),
    ).thenAnswer((_) async => const Right([]));

    final result = await useCase();

    expect(result, const Right<Failure, List<BlockedPromoter>>([]));
  });

  test('returns Left(ServerFailure) when repository fails', () async {
    const tFailure = ServerFailure(
      message: 'Error al obtener promotores bloqueados',
      statusCode: 500,
    );

    when(
      () => mockRepository.getBlockedPromoters(limit: any(named: 'limit')),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase();

    expect(result, const Left<Failure, List<BlockedPromoter>>(tFailure));
  });

  test('passes custom limit to repository', () async {
    when(
      () => mockRepository.getBlockedPromoters(limit: 10),
    ).thenAnswer((_) async => const Right([]));

    await useCase(limit: 10);

    verify(() => mockRepository.getBlockedPromoters(limit: 10)).called(1);
  });
}
