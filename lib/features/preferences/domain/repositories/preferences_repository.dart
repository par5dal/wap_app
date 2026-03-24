// lib/features/preferences/domain/repositories/preferences_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/preferences/domain/entities/user_preferences.dart';

abstract class PreferencesRepository {
  Future<Either<Failure, UserPreferences>> getPreferences();
  Future<Either<Failure, UserPreferences>> updatePreferences({
    required String lang,
  });
}
