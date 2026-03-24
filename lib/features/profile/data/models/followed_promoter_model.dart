// lib/features/profile/data/models/followed_promoter_model.dart

import 'package:wap_app/features/profile/domain/entities/followed_promoter.dart';

class FollowedPromoterModel {
  final String id;
  final String email;
  final Map<String, dynamic>? profile;

  FollowedPromoterModel({required this.id, required this.email, this.profile});

  factory FollowedPromoterModel.fromJson(Map<String, dynamic> json) {
    return FollowedPromoterModel(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      profile: json['profile'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'profile': profile};
  }

  FollowedPromoter toEntity() {
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

    return FollowedPromoter(
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
