// lib/features/manage_event/domain/usecases/get_categories_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/manage_event/domain/entities/category_entity.dart';
import 'package:wap_app/features/manage_event/domain/repositories/manage_event_repository.dart';

class GetCategoriesUseCase {
  final ManageEventRepository repository;
  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() async {
    return await repository.getCategories();
  }
}
