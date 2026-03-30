// test/features/user_actions/domain/usecases/block_user_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/user_actions/domain/repositories/user_actions_repository.dart';
import 'package:wap_app/features/user_actions/domain/usecases/block_user.dart';

class MockUserActionsRepository extends Mock implements UserActionsRepository {}

void main() {
  late BlockUserUseCase useCase;
  late MockUserActionsRepository mockRepository;

  setUp(() {
    mockRepository = MockUserActionsRepository();
    useCase = BlockUserUseCase(mockRepository);
  });

  const tUserId = 'WG2qFrMKp9XzA3nT8eCvLmBsYd7';

  test('returns Right(null) when repository succeeds', () async {
    when(
      () => mockRepository.blockUser(tUserId),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase(tUserId);

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.blockUser(tUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left(ServerFailure) when repository fails', () async {
    const tFailure = ServerFailure(
      message: 'Error al bloquear el usuario',
      statusCode: 500,
    );
    when(
      () => mockRepository.blockUser(tUserId),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tUserId);

    expect(result, const Left<Failure, void>(tFailure));
    verify(() => mockRepository.blockUser(tUserId)).called(1);
  });
}
