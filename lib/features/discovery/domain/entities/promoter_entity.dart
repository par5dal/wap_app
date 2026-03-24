// lib/features/discovery/domain/entities/promoter_entity.dart

class PromoterEntity {
  final String id;
  final String email;
  final String role;
  final PromoterProfileEntity profile;
  final int followersCount;
  final int eventsCount;

  const PromoterEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
    required this.followersCount,
    required this.eventsCount,
  });

  String get displayName =>
      profile.displayName ??
      '${profile.firstName ?? ''} ${profile.lastName ?? ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromoterEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PromoterProfileEntity {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String? companyName;
  final String? websiteUrl;
  final String? city;
  final String? country;

  const PromoterProfileEntity({
    required this.userId,
    this.firstName,
    this.lastName,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.companyName,
    this.websiteUrl,
    this.city,
    this.country,
  });
}
