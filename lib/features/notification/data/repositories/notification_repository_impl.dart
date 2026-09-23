import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';
import 'package:app_movil_sistema/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() =>
      _handle(_remoteDataSource.getNotifications);

  @override
  Future<Either<Failure, int>> getUnreadCount() =>
      _handle(_remoteDataSource.getUnreadCount);

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) =>
      _handle(() => _remoteDataSource.markAsRead(notificationId));

  @override
  Future<Either<Failure, void>> markAllAsRead() =>
      _handle(_remoteDataSource.markAllAsRead);

  Future<Either<Failure, T>> _handle<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
