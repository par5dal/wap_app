// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) =>
    _ProfileModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      companyName: json['companyName'] as String?,
      taxId: json['taxId'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProfileModelToJson(_ProfileModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'phoneNumber': instance.phoneNumber,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'companyName': instance.companyName,
      'taxId': instance.taxId,
      'websiteUrl': instance.websiteUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
