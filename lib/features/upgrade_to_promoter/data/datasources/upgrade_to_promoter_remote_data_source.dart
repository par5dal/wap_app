// lib/features/upgrade_to_promoter/data/datasources/upgrade_to_promoter_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';

abstract class UpgradeToPromoterRemoteDataSource {
  /// POST /users/me/upgrade-to-promoter
  Future<void> upgradeToPromoter();
}

class UpgradeToPromoterRemoteDataSourceImpl
    implements UpgradeToPromoterRemoteDataSource {
  final Dio dio;

  UpgradeToPromoterRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> upgradeToPromoter() async {
    try {
      final response = await dio.post('/users/me/upgrade-to-promoter');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Error upgrading to promoter',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in upgradeToPromoter', e, null);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode ?? 500,
        );
      } else {
        throw NetworkException(message: e.message ?? 'Network error');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in upgradeToPromoter', e, stackTrace);
      throw ServerException(message: e.toString());
    }
  }
}
