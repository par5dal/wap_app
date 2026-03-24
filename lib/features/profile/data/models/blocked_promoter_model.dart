// lib/features/profile/data/models/blocked_promoter_model.dart

import 'package:wap_app/features/profile/domain/entities/blocked_promoter.dart';

/// Parsea un elemento de la lista `blocked` del endpoint GET /users/me/blocked.
///
/// Estructura esperada:
/// ```json
/// {
///   "blockId": "...",
///   "blockedAt": "...",
///   "user": {
///     "id": "...",
///     "email": "...",
///     "profile": {
///       "first_name": "Carlos",
///       "last_name": "López",
///       "display_name": "Carlos Events",
///       "avatar_url": "https://...",
///       "bio": "..."
///     }
///   }
/// }
/// ```
class BlockedPromoterModel {
  final String id;
  final String email;
  final Map<String, dynamic>? profile;

  BlockedPromoterModel({required this.id, required this.email, this.profile});

  factory BlockedPromoterModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return BlockedPromoterModel(
      id: user['id']?.toString() ?? '',
      email: user['email'] as String? ?? '',
      profile: user['profile'] as Map<String, dynamic>?,
    );
  }

  BlockedPromoter toEntity() {
    String? displayName;
    String firstName = '';
    String lastName = '';
    String? avatarUrl;
    String? bio;

    if (profile != null) {
      displayName = profile!['display_name']?.toString();
      firstName = profile!['first_name']?.toString() ?? '';
      lastName = profile!['last_name']?.toString() ?? '';
      avatarUrl = profile!['avatar_url']?.toString();
      bio = profile!['bio']?.toString();
    }

    return BlockedPromoter(
      id: id,
      email: email,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      bio: bio,
    );
  }
}
