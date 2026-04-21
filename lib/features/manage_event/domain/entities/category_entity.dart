// lib/features/manage_event/domain/entities/category_entity.dart

import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? svg;
  final String? color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.svg,
    this.color,
  });

  @override
  List<Object?> get props => [id, name, slug];
}
