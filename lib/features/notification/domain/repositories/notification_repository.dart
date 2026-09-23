import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/notification_filter.dart';
import 'package:dartz/dartz.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications(
    NotificationFilter filter,
  );
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, int>> getVisibleDays();
  Future<Either<Failure, void>> markAsRead(int notificationId);
  Future<Either<Failure, void>> markAllAsRead();
}
