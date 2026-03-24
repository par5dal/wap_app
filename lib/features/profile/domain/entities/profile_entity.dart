// lib/features/profile/domain/entities/profile_entity.dart

import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? bio;
  final String? avatarUrl;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.userId,
    this.displayName,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.phoneNumber,
    this.bio,
    this.avatarUrl,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName {
    // Usar displayName si existe, sino firstName + lastName
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (firstName == null && lastName == null) return '';
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  bool get isComplete {
    return firstName != null &&
        lastName != null &&
        dateOfBirth != null &&
        address != null;
  }

  @override
  List<Object?> get props => [
    userId,
    displayName,
    firstName,
    lastName,
    dateOfBirth,
    phoneNumber,
    bio,
    avatarUrl,
    address,
    city,
    country,
    postalCode,
    updatedAt,
  ];
}
