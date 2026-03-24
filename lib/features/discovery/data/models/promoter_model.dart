// lib/features/discovery/data/models/promoter_model.dart

import 'package:wap_app/features/discovery/domain/entities/promoter_entity.dart';

class PromoterModel extends PromoterEntity {
  const PromoterModel({
    required super.id,
    required super.email,
    required super.role,
    required super.profile,
    required super.followersCount,
    required super.eventsCount,
  });

  factory PromoterModel.fromJson(Map<String, dynamic> json) {
    return PromoterModel(
      id: json['id'].toString(),
      email: json['email'],
      role: json['role'],
      profile: PromoterProfileModel.fromJson(json['profile']),
      followersCount: json['followers_count'],
      eventsCount: json['events_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'profile': (profile as PromoterProfileModel).toJson(),
      'followers_count': followersCount,
      'events_count': eventsCount,
    };
  }
}

class PromoterProfileModel extends PromoterProfileEntity {
  const PromoterProfileModel({
    required super.userId,
    super.firstName,
    super.lastName,
    super.displayName,
    super.bio,
    super.avatarUrl,
    super.companyName,
    super.websiteUrl,
    super.city,
    super.country,
  });

  factory PromoterProfileModel.fromJson(Map<String, dynamic> json) {
    return PromoterProfileModel(
      userId: json['user_id'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      displayName: json['display_name'],
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      companyName: json['company_name'],
      websiteUrl: json['website_url'],
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'company_name': companyName,
      'website_url': websiteUrl,
      'city': city,
      'country': country,
    };
  }
}
