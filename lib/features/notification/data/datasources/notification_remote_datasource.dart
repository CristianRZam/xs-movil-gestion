import 'package:app_movil_sistema/features/notification/data/models/notification_model.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/notification_filter.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications(NotificationFilter filter);
  Future<int> getUnreadCount();
  Future<int> getVisibleDays();
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
}
