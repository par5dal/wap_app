// lib/features/profile/domain/entities/followed_promoter.dart

class FollowedPromoter {
  final String id;
  final String email;
  final String? displayName;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? bio;

  FollowedPromoter({
    required this.id,
    required this.email,
    this.displayName,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.bio,
  });

  String get fullName {
    // Usar displayName si existe, sino firstName + lastName
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Sin nombre';
  }
}
