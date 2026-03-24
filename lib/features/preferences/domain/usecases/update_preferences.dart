// lib/features/preferences/domain/usecases/update_preferences.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/preferences/domain/entities/user_preferences.dart';
import 'package:wap_app/features/preferences/domain/repositories/preferences_repository.dart';

class UpdatePreferencesUseCase {
  final PreferencesRepository repository;
  UpdatePreferencesUseCase(this.repository);

  Future<Either<Failure, UserPreferences>> call({required String lang}) =>
      repository.updatePreferences(lang: lang);
}
