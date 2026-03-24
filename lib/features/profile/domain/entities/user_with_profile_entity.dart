// lib/features/profile/domain/entities/user_with_profile_entity.dart

import 'package:equatable/equatable.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';

class UserWithProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? role;
  final bool? isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileEntity? profile;

  const UserWithProfileEntity({
    required this.id,
    required this.email,
    this.role,
    this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    isActive,
    createdAt,
    updatedAt,
    profile,
  ];
}
