// lib/features/discovery/data/models/category_model.dart

import 'package:wap_app/features/discovery/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    required super.color,
    required super.svg,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'], // Puede ser null
      color: json['color'] ?? '#6366F1', // Color por defecto si no viene
      svg: json['svg'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : now, // Fecha por defecto
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : now, // Fecha por defecto
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'color': color,
      'svg': svg,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
