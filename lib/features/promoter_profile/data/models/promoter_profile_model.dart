// lib/features/promoter_profile/data/models/promoter_profile_model.dart

import 'package:wap_app/features/promoter_profile/domain/entities/promoter_profile.dart';

class PromoterProfileModel {
  final String id;
  final String email;
  final String? role;
  final ProfileData? profile;
  final int followersCount;
  final int eventsCount;
  final bool isFollowing;

  PromoterProfileModel({
    required this.id,
    required this.email,
    this.role,
    this.profile,
    required this.followersCount,
    required this.eventsCount,
    required this.isFollowing,
  });

  factory PromoterProfileModel.fromJson(Map<String, dynamic> json) {
    return PromoterProfileModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      role: json['role'] as String?,
      profile: json['profile'] != null
          ? ProfileData.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      followersCount: json['followers_count'] as int? ?? 0,
      eventsCount: json['events_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  PromoterProfile toEntity() {
    return PromoterProfile(
      id: id,
      email: email,
      displayName: profile?.displayName,
      firstName: profile?.firstName,
      lastName: profile?.lastName,
      avatarUrl: profile?.avatarUrl,
      bio: profile?.bio,
      companyName: profile?.companyName,
      websiteUrl: profile?.websiteUrl,
      city: profile?.city,
      country: profile?.country,
      followersCount: followersCount,
      eventsCount: eventsCount,
      isFollowing: isFollowing,
    );
  }
}

class ProfileData {
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? bio;
  final String? companyName;
  final String? websiteUrl;
  final String? city;
  final String? country;

  ProfileData({
    this.displayName,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.bio,
    this.companyName,
    this.websiteUrl,
    this.city,
    this.country,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      displayName: json['display_name'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      companyName: json['company_name'] as String?,
      websiteUrl: json['website_url'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }
}
