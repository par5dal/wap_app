// lib/features/profile/domain/entities/blocked_promoter.dart

class BlockedPromoter {
  final String id;
  final String email;
  final String? displayName;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? bio;

  BlockedPromoter({
    required this.id,
    required this.email,
    this.displayName,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.bio,
  });

  String get fullName {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Sin nombre';
  }
}
