// test/features/auth/domain/usecases/login_user_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/features/auth/domain/usecases/login_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUser(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tToken = const TokenEntity();

  test('should return TokenEntity when repository succeeds', () async {
    when(
      () => mockRepository.login(tEmail, tPassword),
    ).thenAnswer((_) async => Right(tToken));

    final result = await useCase(
      const LoginParams(email: tEmail, password: tPassword),
    );

    expect(result, Right(tToken));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    const tFailure = ServerFailure(
      message: 'Invalid credentials',
      statusCode: 401,
    );

    when(
      () => mockRepository.login(tEmail, tPassword),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(
      const LoginParams(email: tEmail, password: tPassword),
    );

    expect(result, const Left(tFailure));
  });
}
