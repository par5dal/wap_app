// test/features/auth/presentation/bloc/auth_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/usecases/check_email_exists.dart';
import 'package:wap_app/features/auth/domain/usecases/login_user.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_apple.dart';
import 'package:wap_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:wap_app/features/auth/domain/usecases/register_user.dart';
import 'package:wap_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockLoginUser extends Mock implements LoginUser {}

class MockRegisterUser extends Mock implements RegisterUserUseCase {}

class MockLoginWithGoogle extends Mock implements LoginWithGoogleUseCase {}

class MockLoginWithApple extends Mock implements LoginWithAppleUseCase {}

class MockCheckEmailExists extends Mock implements CheckEmailExistsUseCase {}

class MockAppBloc extends Mock implements AppBloc {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

// ── Helpers ───────────────────────────────────────────────────────────────────

const tFailure = ServerFailure(message: 'Invalid credentials');

AuthUserEntity tAuthUser({
  bool profileComplete = true,
  bool isNewUser = false,
  String authProvider = 'email',
}) => AuthUserEntity(
  id: 'u1',
  email: 'test@test.com',
  role: 'CONSUMER',
  profileComplete: profileComplete,
  emailVerified: true,
  authProvider: authProvider,
);

TokenEntity tToken({
  bool profileComplete = true,
  bool isNewUser = false,
  String authProvider = 'email',
}) => TokenEntity(
  user: tAuthUser(profileComplete: profileComplete, authProvider: authProvider),
  isNewUser: isNewUser,
);

void main() {
  late AuthBloc bloc;
  late MockLoginUser mockLogin;
  late MockRegisterUser mockRegister;
  late MockLoginWithGoogle mockGoogle;
  late MockLoginWithApple mockApple;
  late MockCheckEmailExists mockCheckEmail;
  late MockAppBloc mockAppBloc;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterParams(
        email: '',
        password: '',
        firstName: '',
        lastName: '',
      ),
    );
    registerFallbackValue(const AppAuthStatusChanged(AuthStatus.authenticated));
    registerFallbackValue(const AppTermsNotAccepted(requiredVersion: ''));
  });

  setUp(() {
    mockLogin = MockLoginUser();
    mockRegister = MockRegisterUser();
    mockGoogle = MockLoginWithGoogle();
    mockApple = MockLoginWithApple();
    mockCheckEmail = MockCheckEmailExists();
    mockAppBloc = MockAppBloc();
    mockPrefs = MockSharedPreferences();

    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockAppBloc.add(any())).thenReturn(null);

    bloc = AuthBloc(
      loginUser: mockLogin,
      registerUser: mockRegister,
      loginWithGoogle: mockGoogle,
      loginWithApple: mockApple,
      checkEmailExists: mockCheckEmail,
      appBloc: mockAppBloc,
      prefs: mockPrefs,
    );
  });

  tearDown(() => bloc.close());

  // ── LoginButtonPressed ─────────────────────────────────────────────────────
  group('LoginButtonPressed', () {
    const tEvent = LoginButtonPressed(email: 'a@b.com', password: 'pass123');

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Success] on successful login',
      build: () {
        when(() => mockLogin(any())).thenAnswer((_) async => Right(tToken()));
        return bloc;
      },
      act: (b) => b.add(tEvent),
      expect: () => [isA<AuthFormLoading>(), isA<AuthFormSuccess>()],
      verify: (_) {
        verify(() => mockAppBloc.add(any())).called(1);
        verify(
          () => mockPrefs.setString('cached_auth_provider', 'email'),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Failure] on failed login',
      build: () {
        when(
          () => mockLogin(any()),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (b) => b.add(tEvent),
      expect: () => [
        isA<AuthFormLoading>(),
        const AuthFormFailure('Invalid credentials'),
      ],
    );
  });

  // ── RegisterButtonPressed ──────────────────────────────────────────────────
  group('RegisterButtonPressed', () {
    const tEvent = RegisterButtonPressed(
      email: 'new@test.com',
      password: 'secure',
      firstName: 'Jane',
      lastName: 'Doe',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Success] on successful registration',
      build: () {
        when(
          () => mockRegister(any()),
        ).thenAnswer((_) async => Right(tToken()));
        return bloc;
      },
      act: (b) => b.add(tEvent),
      expect: () => [isA<AuthFormLoading>(), isA<AuthFormSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Failure] on failed registration',
      build: () {
        when(
          () => mockRegister(any()),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (b) => b.add(tEvent),
      expect: () => [
        isA<AuthFormLoading>(),
        const AuthFormFailure('Invalid credentials'),
      ],
    );
  });

  // ── GoogleSignInPressed ────────────────────────────────────────────────────
  group('GoogleSignInPressed', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Success] on Google sign-in success (existing user)',
      build: () {
        when(
          () => mockGoogle(),
        ).thenAnswer((_) async => Right(tToken(authProvider: 'google')));
        return bloc;
      },
      act: (b) => b.add(const GoogleSignInPressed()),
      expect: () => [isA<AuthFormLoading>(), isA<AuthFormSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Success(ProfileIncomplete)] when profile is not complete',
      build: () {
        when(() => mockGoogle()).thenAnswer(
          (_) async =>
              Right(tToken(profileComplete: false, authProvider: 'google')),
        );
        return bloc;
      },
      act: (b) => b.add(const GoogleSignInPressed()),
      expect: () => [
        isA<AuthFormLoading>(),
        isA<AuthFormSuccessProfileIncomplete>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Failure] on Google sign-in failure',
      build: () {
        when(() => mockGoogle()).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (b) => b.add(const GoogleSignInPressed()),
      expect: () => [
        isA<AuthFormLoading>(),
        const AuthFormFailure('Invalid credentials'),
      ],
    );
  });

  // ── AppleSignInPressed ─────────────────────────────────────────────────────
  group('AppleSignInPressed', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Success] on Apple sign-in success (existing user)',
      build: () {
        when(
          () => mockApple(),
        ).thenAnswer((_) async => Right(tToken(authProvider: 'apple')));
        return bloc;
      },
      act: (b) => b.add(const AppleSignInPressed()),
      expect: () => [isA<AuthFormLoading>(), isA<AuthFormSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Failure] on Apple sign-in failure',
      build: () {
        when(() => mockApple()).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (b) => b.add(const AppleSignInPressed()),
      expect: () => [
        isA<AuthFormLoading>(),
        const AuthFormFailure('Invalid credentials'),
      ],
    );
  });
}
