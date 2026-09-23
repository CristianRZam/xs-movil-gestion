import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';
import 'package:app_movil_sistema/features/notification/domain/usecases/notification_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  final NotificationStatus status;
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    int? unreadCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, unreadCount, errorMessage];
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(
    this._getNotifications,
    this._getUnreadCount,
    this._markAsRead,
    this._markAllAsRead,
  ) : super(const NotificationState());

  final GetNotificationsUseCase _getNotifications;
  final GetUnreadNotificationCountUseCase _getUnreadCount;
  final MarkNotificationAsReadUseCase _markAsRead;
  final MarkAllNotificationsAsReadUseCase _markAllAsRead;

  Future<void> loadUnreadCount() async {
    final result = await _getUnreadCount();
    result.fold(
      (_) {},
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationStatus.loading, clearError: true));
    final result = await _getNotifications();
    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
      (notifications) => emit(state.copyWith(
        status: NotificationStatus.success,
        notifications: notifications,
        unreadCount: notifications.where((notification) => !notification.read).length,
      )),
    );
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.read) return;
    final result = await _markAsRead(notification.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final now = DateTime.now();
        final updated = state.notifications
            .map((item) => item.id == notification.id
                ? AppNotification(
                    id: item.id,
                    type: item.type,
                    priority: item.priority,
                    title: item.title,
                    message: item.message,
                    referenceType: item.referenceType,
                    referenceId: item.referenceId,
                    metadata: item.metadata,
                    createdAt: item.createdAt,
                    read: true,
                    readAt: now,
                  )
                : item)
            .toList();
        emit(state.copyWith(
          notifications: updated,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          clearError: true,
        ));
      },
    );
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;
    final result = await _markAllAsRead();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        notifications: state.notifications
            .map((item) => item.read
                ? item
                : AppNotification(
                    id: item.id,
                    type: item.type,
                    priority: item.priority,
                    title: item.title,
                    message: item.message,
                    referenceType: item.referenceType,
                    referenceId: item.referenceId,
                    metadata: item.metadata,
                    createdAt: item.createdAt,
                    read: true,
                    readAt: DateTime.now(),
                  ))
            .toList(),
        unreadCount: 0,
        clearError: true,
      )),
    );
  }
}
