// test/features/auth/domain/usecases/register_user_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/features/auth/domain/usecases/register_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUserUseCase(mockRepository);
  });

  const tParams = RegisterParams(
    email: 'new@example.com',
    password: 'secret123',
    firstName: 'Ana',
    lastName: 'García',
  );
  final tToken = TokenEntity(
    accessToken: 'access',
    refreshToken: 'refresh',
    isNewUser: true,
  );

  test('should return TokenEntity with isNewUser=true on success', () async {
    when(
      () => mockRepository.register(
        tParams.email,
        tParams.password,
        tParams.firstName,
        tParams.lastName,
      ),
    ).thenAnswer((_) async => Right(tToken));

    final result = await useCase(tParams);

    expect(result, Right(tToken));
    expect(result.getOrElse(() => throw Exception()).isNewUser, true);
    verify(
      () => mockRepository.register(
        tParams.email,
        tParams.password,
        tParams.firstName,
        tParams.lastName,
      ),
    ).called(1);
  });

  test('should return failure when email is already taken', () async {
    const tFailure = ServerFailure(
      message: 'Email already exists',
      statusCode: 409,
    );

    when(
      () => mockRepository.register(any(), any(), any(), any()),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tParams);

    expect(result, const Left(tFailure));
  });
}
