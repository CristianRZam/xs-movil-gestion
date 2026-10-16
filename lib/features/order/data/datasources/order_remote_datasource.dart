import 'package:app_movil_sistema/features/order/data/models/order_model.dart';
import 'package:app_movil_sistema/features/order/data/models/order_page_model.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_status_history.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';

abstract class OrderRemoteDataSource {
  Future<OrderPageModel> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
    String? status,
    String? search,
    int? productId,
  });
  Future<OrderPageModel> getKitchenQueue({int page = 0, int size = 20});
  Future<OrderModel> getById(int id);
  Future<OrderModel> create(OrderModel order);
  Future<OrderModel> update(int id, OrderModel order);
  Future<OrderModel> updateStatus(int id, String status);
  Future<OrderModel> addItem(int orderId, OrderItemModel item);
  Future<OrderModel> addItems(int orderId, List<OrderItemModel> items);
  Future<OrderModel> updatePendingItem(int orderId, int itemId, OrderItemModel item);
  Future<OrderModel> splitPendingItem(int orderId, int itemId, double quantity, String fulfillmentType);
  Future<OrderModel> updateItemStatus(int orderId, int itemId, String status, {String? comment, bool fromKitchen = false});
  Future<OrderModel> updateItemsStatus(int orderId, List<int> itemIds, String status, {String? comment, bool fromKitchen = false});
  Future<OrderModel> cancelPendingItem(int orderId, int itemId, {required String comment, required String stockDisposition});
  Future<OrderModel> reportIncident(int orderId, int itemId, String resolution, String reason, {double? discountAmount});
  Future<List<OrderItemIncident>> getIncidents(int orderId);
  Future<List<OrderItemStatusHistory>> getItemStatusHistory(int orderId, int itemId);
  Future<bool> delete(int id);
}
