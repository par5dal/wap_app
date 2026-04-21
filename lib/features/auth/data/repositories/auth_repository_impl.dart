// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/error_handler.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TokenEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final tokenModel = await remoteDataSource.login(email, password);
      return Right(tokenModel);
    } catch (error, stackTrace) {
      AppLogger.error('Error during login', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> register(
    String email,
    String password,
    String firstName,
    String lastName, {
    String role = 'CONSUMER',
  }) async {
    try {
      final tokenModel = await remoteDataSource.register(
        email,
        password,
        firstName,
        lastName,
        role: role,
      );
      return Right(tokenModel);
    } catch (error, stackTrace) {
      AppLogger.error('Error during registration', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> loginWithGoogle() async {
    try {
      final tokenModel = await remoteDataSource.loginWithGoogle();
      return Right(tokenModel);
    } catch (error, stackTrace) {
      AppLogger.error('Error durante login con Google', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> loginWithApple() async {
    try {
      final tokenModel = await remoteDataSource.loginWithApple();
      return Right(tokenModel);
    } catch (error, stackTrace) {
      AppLogger.error('Error durante login con Apple', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (error, stackTrace) {
      AppLogger.error('Error during logout', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    try {
      final exists = await remoteDataSource.checkEmailExists(email);
      return Right(exists);
    } catch (error, stackTrace) {
      AppLogger.error('Error checking if email exists', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, String>> getTermsInfo() async {
    try {
      final version = await remoteDataSource.getTermsInfo();
      return Right(version);
    } catch (error, stackTrace) {
      AppLogger.error('Error getting terms info', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> acceptTerms(String version) async {
    try {
      await remoteDataSource.acceptTerms(version);
      return const Right(null);
    } catch (error, stackTrace) {
      AppLogger.error('Error accepting terms', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, LegalDocument>> getLegalDocument(
    String type,
    String lang,
  ) async {
    try {
      final documentModel = await remoteDataSource.getLegalDocument(type, lang);
      return Right(documentModel.toEntity());
    } catch (error, stackTrace) {
      AppLogger.error('Error getting legal document', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> createProfile(
    String firstName,
    String lastName,
  ) async {
    try {
      await remoteDataSource.createProfile(firstName, lastName);
      return const Right(null);
    } catch (error, stackTrace) {
      AppLogger.error('Error creating profile', error, stackTrace);
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> checkUserStatus() async {
    try {
      await remoteDataSource.checkUserStatus();
      return const Right(null);
    } catch (error, stackTrace) {
      final failure = ErrorHandler.handleException(error, stackTrace);
      return Left(failure);
    }
  }
}
