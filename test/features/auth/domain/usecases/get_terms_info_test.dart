// test/features/auth/domain/usecases/get_terms_info_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/features/auth/domain/usecases/get_terms_info.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetTermsInfoUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetTermsInfoUseCase(mockRepository);
  });

  test('returns required version string on success', () async {
    when(
      () => mockRepository.getTermsInfo(),
    ).thenAnswer((_) async => const Right('1.2'));

    final result = await useCase();

    expect(result, const Right<Failure, String>('1.2'));
    verify(() => mockRepository.getTermsInfo()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left(failure) when repository fails', () async {
    const tFailure = ServerFailure(message: 'Network error');
    when(
      () => mockRepository.getTermsInfo(),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase();

    expect(result, const Left<Failure, String>(tFailure));
    verify(() => mockRepository.getTermsInfo()).called(1);
  });
}
