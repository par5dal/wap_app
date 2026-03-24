// lib/features/notifications/data/models/user_notification_model.dart

import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';

class UserNotificationModel extends UserNotification {
  const UserNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.data,
    required super.isRead,
    required super.createdAt,
  });

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
