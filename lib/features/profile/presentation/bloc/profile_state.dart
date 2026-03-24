// lib/features/profile/presentation/bloc/profile_state.dart

part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserWithProfileEntity userProfile;

  const ProfileLoaded(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class ProfileUpdating extends ProfileState {
  final UserWithProfileEntity currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object> get props => [currentProfile];
}

class ProfileUploadingAvatar extends ProfileState {
  final UserWithProfileEntity currentProfile;

  const ProfileUploadingAvatar(this.currentProfile);

  @override
  List<Object> get props => [currentProfile];
}

class ProfileError extends ProfileState {
  final String message;
  final UserWithProfileEntity? lastKnownProfile;

  const ProfileError(this.message, {this.lastKnownProfile});

  @override
  List<Object?> get props => [message, lastKnownProfile];
}
