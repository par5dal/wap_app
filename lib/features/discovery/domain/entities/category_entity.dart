// lib/features/discovery/domain/entities/category_entity.dart

class CategoryEntity {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String color;
  final String svg;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.color,
    required this.svg,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
