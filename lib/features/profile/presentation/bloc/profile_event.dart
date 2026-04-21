// lib/features/profile/presentation/bloc/profile_event.dart

part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileReset extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? bio;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? companyName;
  final String? taxId;
  final String? websiteUrl;

  const ProfileUpdateRequested({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.phoneNumber,
    this.bio,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.companyName,
    this.taxId,
    this.websiteUrl,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    dateOfBirth,
    phoneNumber,
    bio,
    address,
    city,
    country,
    postalCode,
    companyName,
    taxId,
    websiteUrl,
  ];
}

class ProfileAvatarUploadRequested extends ProfileEvent {
  final File imageFile;

  const ProfileAvatarUploadRequested(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class ProfileAvatarDeleteRequested extends ProfileEvent {
  final String avatarUrl;

  const ProfileAvatarDeleteRequested(this.avatarUrl);

  @override
  List<Object> get props => [avatarUrl];
}
