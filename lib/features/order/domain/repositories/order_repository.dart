import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_page.dart';
import 'package:dartz/dartz.dart' hide Order;

abstract class OrderRepository {
  Future<Either<Failure, OrderPage>> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
    String? status,
    String? search,
  });
  Future<Either<Failure, Order>> create(Order order);
  Future<Either<Failure, Order>> update(int id, Order order);
  Future<Either<Failure, Order>> updateStatus(int id, String status);
  Future<Either<Failure, bool>> delete(int id);
}
