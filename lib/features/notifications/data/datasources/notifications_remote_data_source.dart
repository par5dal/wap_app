// lib/features/notifications/data/datasources/notifications_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/notifications/data/models/user_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<({List<UserNotificationModel> items, int unreadCount, bool hasMore})>
  getNotifications({int page = 1, int limit = 20});

  Future<int> getUnreadCount();

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> deleteOne(String id);

  Future<void> deleteAll();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<({List<UserNotificationModel> items, int unreadCount, bool hasMore})>
  getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      final rawItems = data['data'] as List<dynamic>? ?? [];
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      final items = rawItems
          .map((e) => UserNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalPages = meta['totalPages'] as int? ?? 1;
      final unreadCount = meta['unread_count'] as int? ?? 0;
      return (
        items: items,
        unreadCount: unreadCount,
        hasMore: page < totalPages,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getNotifications', e, null);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get('/notifications/unread-count');
      return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
    } on DioException catch (e) {
      AppLogger.error('DioException in getUnreadCount', e, null);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      AppLogger.error('DioException in markRead', e, null);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      AppLogger.error('DioException in markAllRead', e, null);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> deleteOne(String id) async {
    try {
      await dio.delete('/notifications/$id');
    } on DioException catch (e) {
      AppLogger.error('DioException in deleteOne', e, null);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await dio.delete('/notifications');
    } on DioException catch (e) {
      AppLogger.error('DioException in deleteAll', e, null);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Server error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
