// lib/features/profile/data/models/profile_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@Freezed(fromJson: true, toJson: true)
sealed class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String userId,
    String? displayName,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? bio,
    String? avatarUrl,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProfileModel;

  // Custom fromJson para transformar snake_case a camelCase
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final updatedAt = DateTime.parse(json['updated_at'] as String);

    // El created_at puede venir del objeto user anidado o directamente
    DateTime createdAt = updatedAt; // Fallback por defecto
    if (json['user'] != null && json['user']['created_at'] != null) {
      createdAt = DateTime.parse(json['user']['created_at'] as String);
    } else if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    }

    return ProfileModel(
      userId: json['user_id'].toString(),
      displayName: json['display_name'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      phoneNumber: json['phone_number'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Custom toJson para transformar camelCase a snake_case
  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth != null
          ? '${dateOfBirth!.year.toString().padLeft(4, '0')}-'
                '${dateOfBirth!.month.toString().padLeft(2, '0')}-'
                '${dateOfBirth!.day.toString().padLeft(2, '0')}'
          : null,
      'phone_number': phoneNumber,
      'bio': bio,
      'avatar_url': avatarUrl,
      'address': address,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

extension ProfileModelX on ProfileModel {
  // Método para convertir a Entity
  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      phoneNumber: phoneNumber,
      bio: bio,
      avatarUrl: avatarUrl,
      address: address,
      city: city,
      country: country,
      postalCode: postalCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
