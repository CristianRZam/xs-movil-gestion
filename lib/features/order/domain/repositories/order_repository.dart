import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_page.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_status_history.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
import 'package:dartz/dartz.dart' hide Order;

abstract class OrderRepository {
  Future<Either<Failure, OrderPage>> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
    String? status,
    String? search,
    int? productId,
  });
  Future<Either<Failure, OrderPage>> getKitchenQueue({int page = 0, int size = 20});
  Future<Either<Failure, Order>> getById(int id);
  Future<Either<Failure, Order>> create(Order order);
  Future<Either<Failure, Order>> update(int id, Order order);
  Future<Either<Failure, Order>> updateStatus(int id, String status);
  Future<Either<Failure, Order>> addItem(int orderId, OrderItem item);
  Future<Either<Failure, Order>> addItems(int orderId, List<OrderItem> items);
  Future<Either<Failure, Order>> updatePendingItem(int orderId, int itemId, OrderItem item);
  Future<Either<Failure, Order>> splitPendingItem(int orderId, int itemId, double quantity, String fulfillmentType);
  Future<Either<Failure, Order>> updateItemStatus(int orderId, int itemId, String status, {String? comment, bool fromKitchen = false});
  Future<Either<Failure, Order>> updateItemsStatus(int orderId, List<int> itemIds, String status, {String? comment, bool fromKitchen = false});
  Future<Either<Failure, Order>> cancelPendingItem(int orderId, int itemId, {required String comment, required String stockDisposition});
  Future<Either<Failure, Order>> reportIncident(int orderId, int itemId, String resolution, String reason, {double? discountAmount});
  Future<Either<Failure, List<OrderItemIncident>>> getIncidents(int orderId);
  Future<Either<Failure, List<OrderItemStatusHistory>>> getItemStatusHistory(int orderId, int itemId);
  Future<Either<Failure, bool>> delete(int id);
}
