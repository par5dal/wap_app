// lib/features/preferences/domain/usecases/get_preferences.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/preferences/domain/entities/user_preferences.dart';
import 'package:wap_app/features/preferences/domain/repositories/preferences_repository.dart';

class GetPreferencesUseCase {
  final PreferencesRepository repository;
  GetPreferencesUseCase(this.repository);

  Future<Either<Failure, UserPreferences>> call() =>
      repository.getPreferences();
}
