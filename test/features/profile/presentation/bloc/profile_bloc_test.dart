// test/features/profile/presentation/bloc/profile_bloc_test.dart

import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';
import 'package:wap_app/features/profile/domain/usecases/delete_avatar.dart';
import 'package:wap_app/features/profile/domain/usecases/get_my_profile.dart';
import 'package:wap_app/features/profile/domain/usecases/update_my_profile.dart';
import 'package:wap_app/features/profile/domain/usecases/upload_avatar.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockGetMyProfile extends Mock implements GetMyProfileUseCase {}

class MockUpdateMyProfile extends Mock implements UpdateMyProfileUseCase {}

class MockUploadAvatar extends Mock implements UploadAvatarUseCase {}

class MockDeleteAvatar extends Mock implements DeleteAvatarUseCase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

// ── Helpers ───────────────────────────────────────────────────────────────────

const tFailure = ServerFailure(message: 'Server error');

ProfileEntity tProfile({String? avatarUrl}) => ProfileEntity(
  userId: 'user-1',
  firstName: 'John',
  lastName: 'Doe',
  avatarUrl: avatarUrl,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

UserWithProfileEntity tUser({String? avatarUrl}) => UserWithProfileEntity(
  id: 'user-1',
  email: 'john@example.com',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  profile: tProfile(avatarUrl: avatarUrl),
);

// ── Main ──────────────────────────────────────────────────────────────────────

void main() {
  late ProfileBloc bloc;
  late MockGetMyProfile mockGetMyProfile;
  late MockUpdateMyProfile mockUpdateMyProfile;
  late MockUploadAvatar mockUploadAvatar;
  late MockDeleteAvatar mockDeleteAvatar;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockGetMyProfile = MockGetMyProfile();
    mockUpdateMyProfile = MockUpdateMyProfile();
    mockUploadAvatar = MockUploadAvatar();
    mockDeleteAvatar = MockDeleteAvatar();
    mockPrefs = MockSharedPreferences();

    bloc = ProfileBloc(
      getMyProfile: mockGetMyProfile,
      updateMyProfile: mockUpdateMyProfile,
      uploadAvatar: mockUploadAvatar,
      deleteAvatar: mockDeleteAvatar,
      prefs: mockPrefs,
    );

    // Default prefs stubs
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getString(any())).thenReturn(null);
  });

  tearDown(() => bloc.close());

  // ── ProfileLoadRequested ───────────────────────────────────────────────────

  group('ProfileLoadRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [Loading, Loaded] on success when avatarUrl is null',
      build: () {
        when(() => mockGetMyProfile()).thenAnswer((_) async => Right(tUser()));
        return bloc;
      },
      act: (b) => b.add(ProfileLoadRequested()),
      expect: () => [isA<ProfileLoading>(), ProfileLoaded(tUser())],
      verify: (_) {
        verify(() => mockPrefs.remove('cached_avatar_url')).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'caches avatarUrl in prefs when profile has one',
      build: () {
        when(() => mockGetMyProfile()).thenAnswer(
          (_) async =>
              Right(tUser(avatarUrl: 'https://example.com/avatar.jpg')),
        );
        return bloc;
      },
      act: (b) => b.add(ProfileLoadRequested()),
      expect: () => [
        isA<ProfileLoading>(),
        ProfileLoaded(tUser(avatarUrl: 'https://example.com/avatar.jpg')),
      ],
      verify: (_) {
        verify(
          () => mockPrefs.setString(
            'cached_avatar_url',
            'https://example.com/avatar.jpg',
          ),
        ).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(
          () => mockGetMyProfile(),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (b) => b.add(ProfileLoadRequested()),
      expect: () => [isA<ProfileLoading>(), const ProfileError('Server error')],
    );
  });

  // ── ProfileReset ───────────────────────────────────────────────────────────

  group('ProfileReset', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileInitial] and clears avatar + auth provider from prefs',
      build: () => bloc,
      act: (b) => b.add(ProfileReset()),
      expect: () => [isA<ProfileInitial>()],
      verify: (_) {
        verify(() => mockPrefs.remove('cached_avatar_url')).called(1);
        verify(() => mockPrefs.remove('cached_auth_provider')).called(1);
      },
    );
  });

  // ── ProfileUpdateRequested ─────────────────────────────────────────────────

  group('ProfileUpdateRequested', () {
    const tEvent = ProfileUpdateRequested(firstName: 'Jane', lastName: 'Smith');

    blocTest<ProfileBloc, ProfileState>(
      'does nothing when current state is not ProfileLoaded',
      build: () => bloc, // initial state is ProfileInitial
      act: (b) => b.add(tEvent),
      expect: () => const <ProfileState>[],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [Updating, Loaded] on success',
      build: () {
        when(
          () => mockUpdateMyProfile(any()),
        ).thenAnswer((_) async => Right(tProfile()));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser()),
      act: (b) => b.add(tEvent),
      expect: () => [ProfileUpdating(tUser()), isA<ProfileLoaded>()],
      verify: (_) {
        verify(() => mockUpdateMyProfile(any())).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [Updating, Error] on failure',
      build: () {
        when(
          () => mockUpdateMyProfile(any()),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser()),
      act: (b) => b.add(tEvent),
      expect: () => [
        ProfileUpdating(tUser()),
        ProfileError('Server error', lastKnownProfile: tUser()),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'passes promoter fields to updateMyProfile when provided',
      build: () {
        when(
          () => mockUpdateMyProfile(any()),
        ).thenAnswer((_) async => Right(tProfile()));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser()),
      act: (b) => b.add(
        const ProfileUpdateRequested(
          companyName: 'Acme Events S.L.',
          taxId: 'B12345678',
          websiteUrl: 'https://acmeevents.com',
        ),
      ),
      expect: () => [ProfileUpdating(tUser()), isA<ProfileLoaded>()],
      verify: (_) {
        verify(
          () => mockUpdateMyProfile({
            'company_name': 'Acme Events S.L.',
            'tax_id': 'B12345678',
            'website_url': 'https://acmeevents.com',
          }),
        ).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'does not include promoter fields in payload when null',
      build: () {
        when(
          () => mockUpdateMyProfile(any()),
        ).thenAnswer((_) async => Right(tProfile()));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser()),
      act: (b) => b.add(const ProfileUpdateRequested(firstName: 'Jane')),
      verify: (_) {
        final captured =
            verify(() => mockUpdateMyProfile(captureAny())).captured.single
                as Map<String, dynamic>;
        expect(captured.containsKey('company_name'), isFalse);
        expect(captured.containsKey('tax_id'), isFalse);
        expect(captured.containsKey('website_url'), isFalse);
      },
    );
  });

  // ── ProfileAvatarUploadRequested ───────────────────────────────────────────

  group('ProfileAvatarUploadRequested', () {
    final tFile = File('test_image.jpg');
    final tEvent = ProfileAvatarUploadRequested(tFile);

    blocTest<ProfileBloc, ProfileState>(
      'does nothing when current state is not ProfileLoaded',
      build: () => bloc,
      act: (b) => b.add(tEvent),
      expect: () => const <ProfileState>[],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [UploadingAvatar, Error] when upload fails',
      build: () {
        when(
          () => mockUploadAvatar(any()),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser()),
      act: (b) => b.add(tEvent),
      expect: () => [
        ProfileUploadingAvatar(tUser()),
        ProfileError('Server error', lastKnownProfile: tUser()),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [UploadingAvatar, Error] when upload succeeds but profile update fails',
      build: () {
        when(
          () => mockUploadAvatar(any()),
        ).thenAnswer((_) async => const Right('https://example.com/new.jpg'));
        when(
          () => mockUpdateMyProfile(any()),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser()),
      act: (b) => b.add(tEvent),
      expect: () => [
        ProfileUploadingAvatar(tUser()),
        ProfileError('Server error', lastKnownProfile: tUser()),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [UploadingAvatar, Loaded] on full success and caches new avatarUrl',
      build: () {
        when(
          () => mockUploadAvatar(any()),
        ).thenAnswer((_) async => const Right('https://example.com/new.jpg'));
        when(() => mockUpdateMyProfile(any())).thenAnswer(
          (_) async =>
              Right(tProfile(avatarUrl: 'https://example.com/new.jpg')),
        );
        return bloc;
      },
      seed: () => ProfileLoaded(tUser()),
      act: (b) => b.add(tEvent),
      expect: () => [ProfileUploadingAvatar(tUser()), isA<ProfileLoaded>()],
      verify: (_) {
        verify(
          () => mockPrefs.setString(
            'cached_avatar_url',
            'https://example.com/new.jpg',
          ),
        ).called(1);
      },
    );
  });

  // ── ProfileAvatarDeleteRequested ───────────────────────────────────────────

  group('ProfileAvatarDeleteRequested', () {
    const tAvatarUrl = 'https://example.com/avatar.jpg';
    const tEvent = ProfileAvatarDeleteRequested(tAvatarUrl);

    blocTest<ProfileBloc, ProfileState>(
      'does nothing when current state is not ProfileLoaded',
      build: () => bloc,
      act: (b) => b.add(tEvent),
      expect: () => const <ProfileState>[],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [UploadingAvatar, Loaded] on success and removes avatar from prefs',
      build: () {
        when(
          () => mockDeleteAvatar(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockUpdateMyProfile(any()),
        ).thenAnswer((_) async => Right(tProfile()));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser(avatarUrl: tAvatarUrl)),
      act: (b) => b.add(tEvent),
      expect: () => [
        ProfileUploadingAvatar(tUser(avatarUrl: tAvatarUrl)),
        isA<ProfileLoaded>(),
      ],
      verify: (_) {
        verify(() => mockPrefs.remove('cached_avatar_url')).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [UploadingAvatar, Error] when profile update fails (Cloudinary delete ignored)',
      build: () {
        when(
          () => mockDeleteAvatar(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockUpdateMyProfile(any()),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      seed: () => ProfileLoaded(tUser(avatarUrl: tAvatarUrl)),
      act: (b) => b.add(tEvent),
      expect: () => [
        ProfileUploadingAvatar(tUser(avatarUrl: tAvatarUrl)),
        ProfileError(
          'Server error',
          lastKnownProfile: tUser(avatarUrl: tAvatarUrl),
        ),
      ],
    );
  });

  // ── getCachedAvatarUrl ─────────────────────────────────────────────────────

  group('getCachedAvatarUrl', () {
    test('returns value from prefs', () {
      when(
        () => mockPrefs.getString('cached_avatar_url'),
      ).thenReturn('https://example.com/cached.jpg');

      expect(bloc.getCachedAvatarUrl(), 'https://example.com/cached.jpg');
    });

    test('returns null when prefs has no entry', () {
      when(() => mockPrefs.getString('cached_avatar_url')).thenReturn(null);

      expect(bloc.getCachedAvatarUrl(), isNull);
    });
  });
}
