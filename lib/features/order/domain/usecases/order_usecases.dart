import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_page.dart';
import 'package:app_movil_sistema/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart' hide Order;

class GetOrdersUseCase {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);
  Future<Either<Failure, OrderPage>> call({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
    String? status,
    String? search,
  }) => repository.getAll(
    page: page,
    size: size,
    from: from,
    to: to,
    status: status,
    search: search,
  );
}

class CreateOrderUseCase {
  final OrderRepository repository;
  CreateOrderUseCase(this.repository);
  Future<Either<Failure, Order>> call(Order order) => repository.create(order);
}

class UpdateOrderUseCase {
  final OrderRepository repository;
  UpdateOrderUseCase(this.repository);
  Future<Either<Failure, Order>> call(int id, Order order) =>
      repository.update(id, order);
}

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  UpdateOrderStatusUseCase(this.repository);
  Future<Either<Failure, Order>> call(int id, String status) =>
      repository.updateStatus(id, status);
}

class DeleteOrderUseCase {
  final OrderRepository repository;
  DeleteOrderUseCase(this.repository);
  Future<Either<Failure, bool>> call(int id) => repository.delete(id);
}
