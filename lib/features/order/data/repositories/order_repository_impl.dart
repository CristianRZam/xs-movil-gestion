import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/order/data/datasources/order_remote_datasource.dart';
import 'package:app_movil_sistema/features/order/data/models/order_model.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_page.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_status_history.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
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
    String? status,
    String? search,
  }) => _handle(
    () async => (await remoteDataSource.getAll(
      page: page,
      size: size,
      from: from,
      to: to,
      status: status,
      search: search,
    )).toEntity(),
  );
  @override
  Future<Either<Failure, OrderPage>> getKitchenQueue({int page = 0, int size = 20}) =>
      _handle(() async => (await remoteDataSource.getKitchenQueue(page: page, size: size)).toEntity());
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
  Future<Either<Failure, Order>> addItem(int orderId, OrderItem item) =>
      _handle(() => remoteDataSource.addItem(orderId, OrderItemModel.fromEntity(item)));
  @override
  Future<Either<Failure, Order>> addItems(int orderId, List<OrderItem> items) =>
      _handle(
        () => remoteDataSource.addItems(
          orderId,
          items.map(OrderItemModel.fromEntity).toList(),
        ),
      );
  @override
  Future<Either<Failure, Order>> updatePendingItem(
    int orderId,
    int itemId,
    OrderItem item,
  ) => _handle(
    () => remoteDataSource.updatePendingItem(
      orderId,
      itemId,
      OrderItemModel.fromEntity(item),
    ),
  );
  @override
  Future<Either<Failure, Order>> updateItemStatus(int orderId, int itemId, String status, {String? comment}) =>
      _handle(() => remoteDataSource.updateItemStatus(orderId, itemId, status, comment: comment));
  @override
  Future<Either<Failure, Order>> updateItemsStatus(int orderId, List<int> itemIds, String status, {String? comment}) =>
      _handle(() => remoteDataSource.updateItemsStatus(orderId, itemIds, status, comment: comment));
  @override
  Future<Either<Failure, Order>> cancelPendingItem(int orderId, int itemId, {required String comment, required String stockDisposition}) =>
      _handle(() => remoteDataSource.cancelPendingItem(orderId, itemId, comment: comment, stockDisposition: stockDisposition));
  @override
  Future<Either<Failure, Order>> reportIncident(int orderId, int itemId, String resolution, String reason, {double? discountAmount}) =>
      _handle(() => remoteDataSource.reportIncident(orderId, itemId, resolution, reason, discountAmount: discountAmount));
  @override
  Future<Either<Failure, List<OrderItemIncident>>> getIncidents(int orderId) => _handle(() => remoteDataSource.getIncidents(orderId));
  @override
  Future<Either<Failure, List<OrderItemStatusHistory>>> getItemStatusHistory(int orderId, int itemId) =>
      _handle(() => remoteDataSource.getItemStatusHistory(orderId, itemId));
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
