import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/order/data/datasources/order_remote_datasource.dart';
import 'package:app_movil_sistema/features/order/data/models/order_model.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_page.dart';
import 'package:app_movil_sistema/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, OrderPage>> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
  }) => _handle(
    () async => (await remoteDataSource.getAll(
      page: page,
      size: size,
      from: from,
      to: to,
    )).toEntity(),
  );
  @override
  Future<Either<Failure, Order>> create(Order order) =>
      _handle(() => remoteDataSource.create(OrderModel.fromEntity(order)));
  @override
  Future<Either<Failure, Order>> update(int id, Order order) =>
      _handle(() => remoteDataSource.update(id, OrderModel.fromEntity(order)));
  @override
  Future<Either<Failure, Order>> updateStatus(int id, String status) =>
      _handle(() => remoteDataSource.updateStatus(id, status));
  @override
  Future<Either<Failure, bool>> delete(int id) =>
      _handle(() => remoteDataSource.delete(id));

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
