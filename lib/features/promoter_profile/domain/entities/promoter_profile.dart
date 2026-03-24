// lib/features/promoter_profile/domain/entities/promoter_profile.dart

import 'package:equatable/equatable.dart';

class PromoterProfile extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? bio;
  final String? companyName;
  final String? websiteUrl;
  final String? city;
  final String? country;
  final int followersCount;
  final int eventsCount;
  final bool isFollowing;

  const PromoterProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.bio,
    this.companyName,
    this.websiteUrl,
    this.city,
    this.country,
    required this.followersCount,
    required this.eventsCount,
    required this.isFollowing,
  });

  String get fullName {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (firstName == null && lastName == null) return email;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  String? get location {
    if (city != null && country != null) {
      return '$city, $country';
    }
    return city ?? country;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    firstName,
    lastName,
    avatarUrl,
    bio,
    companyName,
    websiteUrl,
    city,
    country,
    followersCount,
    eventsCount,
    isFollowing,
  ];
}
