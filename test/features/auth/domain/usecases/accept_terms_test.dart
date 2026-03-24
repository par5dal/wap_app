// test/features/auth/domain/usecases/accept_terms_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/features/auth/domain/usecases/accept_terms.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AcceptTermsUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = AcceptTermsUseCase(mockRepository);
  });

  const tVersion = '1.2';

  test('returns Right(null) when repository succeeds', () async {
    when(
      () => mockRepository.acceptTerms(tVersion),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase(tVersion);

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.acceptTerms(tVersion)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left(failure) when repository fails', () async {
    const tFailure = ServerFailure(
      message: 'Error al aceptar los términos',
      statusCode: 400,
    );
    when(
      () => mockRepository.acceptTerms(tVersion),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tVersion);

    expect(result, const Left<Failure, void>(tFailure));
    verify(() => mockRepository.acceptTerms(tVersion)).called(1);
  });
}
