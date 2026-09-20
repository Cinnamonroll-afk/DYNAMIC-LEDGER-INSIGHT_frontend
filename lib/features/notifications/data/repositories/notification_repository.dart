import 'dart:async';
import 'package:fincontrol/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications(String userId) async* {
    yield [];
  }

  Future<void> markAsRead(String id) async {
  }

  Future<void> markAllAsRead(String userId) async {
  }

  Future<void> deleteNotification(String id) async {
  }
}
