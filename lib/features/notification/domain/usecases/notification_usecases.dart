import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';
import 'package:app_movil_sistema/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);
  final NotificationRepository _repository;
  Future<Either<Failure, List<AppNotification>>> call() =>
      _repository.getNotifications();
}

class GetUnreadNotificationCountUseCase {
  const GetUnreadNotificationCountUseCase(this._repository);
  final NotificationRepository _repository;
  Future<Either<Failure, int>> call() => _repository.getUnreadCount();
}

class MarkNotificationAsReadUseCase {
  const MarkNotificationAsReadUseCase(this._repository);
  final NotificationRepository _repository;
  Future<Either<Failure, void>> call(int notificationId) =>
      _repository.markAsRead(notificationId);
}

class MarkAllNotificationsAsReadUseCase {
  const MarkAllNotificationsAsReadUseCase(this._repository);
  final NotificationRepository _repository;
  Future<Either<Failure, void>> call() => _repository.markAllAsRead();
}
