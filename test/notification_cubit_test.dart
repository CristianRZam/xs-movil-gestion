import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/notification_filter.dart';
import 'package:app_movil_sistema/features/notification/domain/repositories/notification_repository.dart';
import 'package:app_movil_sistema/features/notification/domain/usecases/notification_usecases.dart';
import 'package:app_movil_sistema/features/notification/presentation/bloc/notification_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('marking a notification as read updates the shared unread count', () async {
    final unreadNotification = AppNotification(
      id: 10,
      type: 'PAYMENT_RECEIVED',
      priority: 'NORMAL',
      title: 'Pago digital recibido',
      message: 'Yape: S/ 20.00',
      createdAt: DateTime(2026, 9, 22, 11, 42),
      read: false,
    );
    final repository = _NotificationRepositoryFake([unreadNotification]);
    final cubit = NotificationCubit(
      GetNotificationsUseCase(repository),
      GetUnreadNotificationCountUseCase(repository),
      GetNotificationVisibleDaysUseCase(repository),
      MarkNotificationAsReadUseCase(repository),
      MarkAllNotificationsAsReadUseCase(repository),
    );

    await cubit.loadNotifications();
    expect(cubit.state.unreadCount, 1);
    expect(cubit.state.notifications.single.read, isFalse);

    await cubit.markAsRead(unreadNotification);
    expect(cubit.state.unreadCount, 0);
    expect(cubit.state.notifications.single.read, isTrue);
    expect(repository.readNotificationIds, [10]);

    await cubit.close();
  });
}

class _NotificationRepositoryFake implements NotificationRepository {
  _NotificationRepositoryFake(this.notifications);

  final List<AppNotification> notifications;
  final List<int> readNotificationIds = [];

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications(NotificationFilter filter) async =>
      Right(notifications);

  @override
  Future<Either<Failure, int>> getUnreadCount() async =>
      Right(notifications.where((notification) => !notification.read).length);

  @override
  Future<Either<Failure, int>> getVisibleDays() async => const Right(7);

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    readNotificationIds.add(notificationId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async => const Right(null);
}
