// lib/features/profile/presentation/bloc/profile_bloc.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';
import 'package:wap_app/features/profile/domain/usecases/delete_avatar.dart';
import 'package:wap_app/features/profile/domain/usecases/get_my_profile.dart';
import 'package:wap_app/features/profile/domain/usecases/update_my_profile.dart';
import 'package:wap_app/features/profile/domain/usecases/upload_avatar.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetMyProfileUseCase getMyProfile;
  final UpdateMyProfileUseCase updateMyProfile;
  final UploadAvatarUseCase uploadAvatar;
  final DeleteAvatarUseCase deleteAvatar;
  final SharedPreferences prefs;

  ProfileBloc({
    required this.getMyProfile,
    required this.updateMyProfile,
    required this.uploadAvatar,
    required this.deleteAvatar,
    required this.prefs,
  }) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileReset>(_onReset);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileAvatarUploadRequested>(_onAvatarUploadRequested);
    on<ProfileAvatarDeleteRequested>(_onAvatarDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getMyProfile();

    result.fold((failure) => emit(ProfileError(failure.message)), (
      userProfile,
    ) {
      // Cachear solo el avatar URL
      if (userProfile.profile?.avatarUrl != null) {
        prefs.setString('cached_avatar_url', userProfile.profile!.avatarUrl!);
      } else {
        prefs.remove('cached_avatar_url');
      }
      emit(ProfileLoaded(userProfile));
    });
  }

  void _onReset(ProfileReset event, Emitter<ProfileState> emit) {
    // Limpiar cache del avatar y proveedor de auth
    prefs.remove('cached_avatar_url');
    prefs.remove('cached_auth_provider');
    emit(ProfileInitial());
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(currentState.userProfile));

    // Construir mapa con solo los campos que se están actualizando
    final updateData = <String, dynamic>{};

    if (event.firstName != null) updateData['first_name'] = event.firstName;
    if (event.lastName != null) updateData['last_name'] = event.lastName;
    if (event.dateOfBirth != null) {
      // Enviar fecha en formato YYYY-MM-DD
      final date = event.dateOfBirth!;
      final dateString =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      updateData['date_of_birth'] = dateString;
    }
    if (event.phoneNumber != null) {
      updateData['phone_number'] = event.phoneNumber;
    }
    if (event.bio != null) updateData['bio'] = event.bio;
    if (event.address != null) updateData['address'] = event.address;
    if (event.city != null) updateData['city'] = event.city;
    if (event.country != null) updateData['country'] = event.country;
    if (event.postalCode != null) updateData['postal_code'] = event.postalCode;
    if (event.companyName != null) {
      updateData['company_name'] = event.companyName;
    }
    if (event.taxId != null) updateData['tax_id'] = event.taxId;
    if (event.websiteUrl != null) updateData['website_url'] = event.websiteUrl;

    final result = await updateMyProfile(updateData);

    result.fold(
      (failure) => emit(
        ProfileError(
          failure.message,
          lastKnownProfile: currentState.userProfile,
        ),
      ),
      (updatedProfile) {
        // Preservar el avatar_url si el backend no lo devolvió
        final currentAvatarUrl = currentState.userProfile.profile?.avatarUrl;
        final finalAvatarUrl = updatedProfile.avatarUrl ?? currentAvatarUrl;

        // Crear el perfil con el avatar preservado si es necesario
        final finalProfile = ProfileEntity(
          userId: updatedProfile.userId,
          firstName: updatedProfile.firstName,
          lastName: updatedProfile.lastName,
          dateOfBirth: updatedProfile.dateOfBirth,
          phoneNumber: updatedProfile.phoneNumber,
          bio: updatedProfile.bio,
          avatarUrl: finalAvatarUrl,
          address: updatedProfile.address,
          city: updatedProfile.city,
          country: updatedProfile.country,
          postalCode: updatedProfile.postalCode,
          createdAt: updatedProfile.createdAt,
          updatedAt: updatedProfile.updatedAt,
        );

        // Crear nueva instancia manualmente (sin copyWith porque usamos Equatable)
        final updatedUserProfile = UserWithProfileEntity(
          id: currentState.userProfile.id,
          email: currentState.userProfile.email,
          role: currentState.userProfile.role,
          isActive: currentState.userProfile.isActive,
          createdAt: currentState.userProfile.createdAt,
          updatedAt: currentState.userProfile.updatedAt,
          profile: finalProfile,
        );

        // Actualizar caché del avatar
        if (finalAvatarUrl != null) {
          prefs.setString('cached_avatar_url', finalAvatarUrl);
        }

        emit(ProfileLoaded(updatedUserProfile));
      },
    );
  }

  Future<void> _onAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUploadingAvatar(currentState.userProfile));

    // Guardar URL del avatar anterior para borrarlo después
    final oldAvatarUrl = currentState.userProfile.profile?.avatarUrl;

    // 1. Subir nueva imagen a Cloudinary
    final uploadResult = await uploadAvatar(event.imageFile);

    await uploadResult.fold(
      (failure) async {
        emit(
          ProfileError(
            failure.message,
            lastKnownProfile: currentState.userProfile,
          ),
        );
      },
      (newAvatarUrl) async {
        // 2. Actualizar perfil con la nueva URL
        final updateResult = await updateMyProfile({
          'avatar_url': newAvatarUrl,
        });

        updateResult.fold(
          (failure) => emit(
            ProfileError(
              failure.message,
              lastKnownProfile: currentState.userProfile,
            ),
          ),
          (updatedProfile) async {
            final updatedUserProfile = UserWithProfileEntity(
              id: currentState.userProfile.id,
              email: currentState.userProfile.email,
              role: currentState.userProfile.role,
              isActive: currentState.userProfile.isActive,
              createdAt: currentState.userProfile.createdAt,
              updatedAt: currentState.userProfile.updatedAt,
              profile: updatedProfile,
            );

            // 3. Borrar el avatar anterior de Cloudinary (si existía)
            if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
              // No esperamos el resultado, lo hacemos en segundo plano
              deleteAvatar(oldAvatarUrl);
            }

            // Actualizar caché
            prefs.setString('cached_avatar_url', newAvatarUrl);

            emit(ProfileLoaded(updatedUserProfile));
          },
        );
      },
    );
  }

  Future<void> _onAvatarDeleteRequested(
    ProfileAvatarDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUploadingAvatar(currentState.userProfile));

    // 1. PRIMERO eliminar de Cloudinary (mientras aún existe en la BD)
    final deleteResult = await deleteAvatar(event.avatarUrl);

    // Independientemente del resultado de Cloudinary, continuamos
    deleteResult.fold(
      (failure) {
        // Log silencioso - no afecta la experiencia del usuario
      },
      (_) {
        // Eliminación exitosa
      },
    );

    // 2. DESPUÉS actualizar perfil con avatar_url = null
    final updateResult = await updateMyProfile({'avatar_url': null});

    await updateResult.fold(
      (failure) async {
        emit(
          ProfileError(
            failure.message,
            lastKnownProfile: currentState.userProfile,
          ),
        );
      },
      (updatedProfile) async {
        final updatedUserProfile = UserWithProfileEntity(
          id: currentState.userProfile.id,
          email: currentState.userProfile.email,
          role: currentState.userProfile.role,
          isActive: currentState.userProfile.isActive,
          createdAt: currentState.userProfile.createdAt,
          updatedAt: currentState.userProfile.updatedAt,
          profile: updatedProfile,
        );

        // Limpiar caché
        prefs.remove('cached_avatar_url');

        emit(ProfileLoaded(updatedUserProfile));
      },
    );
  }

  // Método helper para obtener avatar cacheado
  String? getCachedAvatarUrl() {
    return prefs.getString('cached_avatar_url');
  }
}
