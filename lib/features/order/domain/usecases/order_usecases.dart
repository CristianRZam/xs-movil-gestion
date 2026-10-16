import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_page.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_status_history.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
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
    int? productId,
  }) => repository.getAll(
    page: page,
    size: size,
    from: from,
    to: to,
    status: status,
    search: search,
    productId: productId,
  );
}

class GetKitchenQueueUseCase {
  final OrderRepository repository;
  GetKitchenQueueUseCase(this.repository);
  Future<Either<Failure, OrderPage>> call({int page = 0, int size = 20}) =>
      repository.getKitchenQueue(page: page, size: size);
}

class GetOrderByIdUseCase {
  final OrderRepository repository;
  GetOrderByIdUseCase(this.repository);
  Future<Either<Failure, Order>> call(int id) => repository.getById(id);
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

class AddOrderItemUseCase {
  final OrderRepository repository;
  AddOrderItemUseCase(this.repository);
  Future<Either<Failure, Order>> call(int orderId, OrderItem item) => repository.addItem(orderId, item);
}

class AddOrderItemsUseCase {
  final OrderRepository repository;
  AddOrderItemsUseCase(this.repository);
  Future<Either<Failure, Order>> call(int orderId, List<OrderItem> items) =>
      repository.addItems(orderId, items);
}

class UpdatePendingOrderItemUseCase {
  final OrderRepository repository;
  UpdatePendingOrderItemUseCase(this.repository);
  Future<Either<Failure, Order>> call(int orderId, int itemId, OrderItem item) =>
      repository.updatePendingItem(orderId, itemId, item);
}

class SplitPendingOrderItemUseCase {
  final OrderRepository repository;
  SplitPendingOrderItemUseCase(this.repository);
  Future<Either<Failure, Order>> call(
    int orderId,
    int itemId,
    double quantity,
    String fulfillmentType,
  ) => repository.splitPendingItem(orderId, itemId, quantity, fulfillmentType);
}

class UpdateOrderItemStatusUseCase {
  final OrderRepository repository;
  UpdateOrderItemStatusUseCase(this.repository);
  Future<Either<Failure, Order>> call(int orderId, int itemId, String status, {String? comment, bool fromKitchen = false}) =>
      repository.updateItemStatus(orderId, itemId, status, comment: comment, fromKitchen: fromKitchen);
}

class UpdateOrderItemsStatusUseCase {
  final OrderRepository repository;
  UpdateOrderItemsStatusUseCase(this.repository);
  Future<Either<Failure, Order>> call(int orderId, List<int> itemIds, String status, {String? comment, bool fromKitchen = false}) =>
      repository.updateItemsStatus(orderId, itemIds, status, comment: comment, fromKitchen: fromKitchen);
}

class CancelPendingOrderItemUseCase {
  final OrderRepository repository;
  CancelPendingOrderItemUseCase(this.repository);
  Future<Either<Failure, Order>> call(int orderId, int itemId, {required String comment, required String stockDisposition}) =>
      repository.cancelPendingItem(orderId, itemId, comment: comment, stockDisposition: stockDisposition);
}

class ReportOrderItemIncidentUseCase {
  final OrderRepository repository;
  ReportOrderItemIncidentUseCase(this.repository);
  Future<Either<Failure, Order>> call(int orderId, int itemId, String resolution, String reason, {double? discountAmount}) =>
      repository.reportIncident(orderId, itemId, resolution, reason, discountAmount: discountAmount);
}

class GetOrderIncidentsUseCase {
  final OrderRepository repository;
  GetOrderIncidentsUseCase(this.repository);
  Future<Either<Failure, List<OrderItemIncident>>> call(int orderId) => repository.getIncidents(orderId);
}

class GetOrderItemStatusHistoryUseCase {
  final OrderRepository repository;
  GetOrderItemStatusHistoryUseCase(this.repository);
  Future<Either<Failure, List<OrderItemStatusHistory>>> call(int orderId, int itemId) =>
      repository.getItemStatusHistory(orderId, itemId);
}

class DeleteOrderUseCase {
  final OrderRepository repository;
  DeleteOrderUseCase(this.repository);
  Future<Either<Failure, bool>> call(int id) => repository.delete(id);
}
