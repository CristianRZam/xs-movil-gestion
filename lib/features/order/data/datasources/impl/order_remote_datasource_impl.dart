import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/order/data/datasources/order_remote_datasource.dart';
import 'package:app_movil_sistema/features/order/data/models/order_model.dart';
import 'package:app_movil_sistema/features/order/data/models/order_page_model.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_status_history.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
import 'package:dio/dio.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;
  OrderRemoteDataSourceImpl(this.apiClient);

  @override
  Future<OrderPageModel> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
    String? status,
    String? search,
    int? productId,
  }) async {
    String date(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final response = await apiClient.dio.get(
      '/orders',
      queryParameters: {
        'page': page,
        'size': size,
        if (from != null) 'fromDate': date(from),
        if (to != null) 'toDate': date(to),
        if (status != null && status != 'ALL') 'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (productId != null) 'productId': productId,
      },
    );
    final api = ApiResponse<OrderPageModel>.fromJson(
      response.data,
      (json) => OrderPageModel.fromJson(json as Map<String, dynamic>),
    );
    _ensureSuccess(api.success, api.message, response);
    if (api.data == null) throw Exception('No se recibieron órdenes');
    return api.data!;
  }

  @override
  Future<OrderPageModel> getKitchenQueue({int page = 0, int size = 20}) async {
    final response = await apiClient.dio.get(
      '/orders/kitchen-queue',
      queryParameters: {'page': page, 'size': size},
    );
    final api = ApiResponse<OrderPageModel>.fromJson(
      response.data,
      (json) => OrderPageModel.fromJson(json as Map<String, dynamic>),
    );
    _ensureSuccess(api.success, api.message, response);
    if (api.data == null) throw Exception('No se recibió la cola de cocina');
    return api.data!;
  }

  @override
  Future<OrderModel> getById(int id) => _save(apiClient.dio.get('/orders/$id'));

  @override
  Future<OrderModel> create(OrderModel order) =>
      _save(apiClient.dio.post('/orders', data: order.toJson()));

  @override
  Future<OrderModel> update(int id, OrderModel order) =>
      _save(apiClient.dio.put('/orders/$id', data: order.toJson()));

  @override
  Future<OrderModel> updateStatus(int id, String status) =>
      _save(apiClient.dio.put('/orders/$id/status', data: {'status': status}));

  @override
  Future<OrderModel> addItem(int orderId, OrderItemModel item) =>
      _save(apiClient.dio.post('/orders/$orderId/items', data: item.toJson()));

  @override
  Future<OrderModel> addItems(int orderId, List<OrderItemModel> items) =>
      _save(
        apiClient.dio.post(
          '/orders/$orderId/items/batch',
          data: {'items': items.map((item) => item.toJson()).toList()},
        ),
      );

  @override
  Future<OrderModel> updatePendingItem(
    int orderId,
    int itemId,
    OrderItemModel item,
  ) => _save(
    apiClient.dio.put('/orders/$orderId/items/$itemId', data: item.toJson()),
  );

  @override
  Future<OrderModel> updateItemStatus(int orderId, int itemId, String status, {String? comment, bool fromKitchen = false}) =>
      _save(apiClient.dio.put(fromKitchen ? '/orders/kitchen/$orderId/items/$itemId/status' : '/orders/$orderId/items/$itemId/status', data: {
        'status': status,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      }));

  @override
  Future<OrderModel> updateItemsStatus(int orderId, List<int> itemIds, String status, {String? comment, bool fromKitchen = false}) =>
      _save(apiClient.dio.put(fromKitchen ? '/orders/kitchen/$orderId/items/status' : '/orders/$orderId/items/status', data: {
        'itemIds': itemIds,
        'status': status,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      }));

  @override
  Future<OrderModel> cancelPendingItem(int orderId, int itemId, {required String comment, required String stockDisposition}) =>
      _save(apiClient.dio.delete('/orders/$orderId/items/$itemId', queryParameters: {
        'comment': comment.trim(),
        'stockDisposition': stockDisposition,
      }));

  @override
  Future<OrderModel> reportIncident(int orderId, int itemId, String resolution, String reason, {double? discountAmount}) =>
      _save(apiClient.dio.post('/orders/$orderId/items/$itemId/incidents', data: {
        'resolution': resolution,
        'reason': reason.trim(),
        if (discountAmount != null) 'discountAmount': discountAmount,
      }));

  @override
  Future<List<OrderItemIncident>> getIncidents(int orderId) async {
    final response = await apiClient.dio.get('/orders/$orderId/incidents');
    final api = ApiResponse<List<OrderItemIncident>>.fromJson(response.data, (json) => (json as List<dynamic>).map((entry) {
      final value = entry as Map<String, dynamic>;
      return OrderItemIncident(id: _asInt(value['id']), orderItemId: _asInt(value['orderItemId']) ?? 0, productId: _asInt(value['productId']) ?? 0, resolution: value['resolution'] as String? ?? '', reason: value['reason'] as String? ?? '', discountAmount: (value['discountAmount'] as num?)?.toDouble() ?? 0, status: value['status'] as String? ?? '', reportedBy: _asInt(value['reportedBy']), reportedAt: _asDate(value['reportedAt']), approvedBy: _asInt(value['approvedBy']), approvedAt: _asDate(value['approvedAt']));
    }).toList());
    _ensureSuccess(api.success, api.message, response);
    return api.data ?? const [];
  }

  @override
  Future<List<OrderItemStatusHistory>> getItemStatusHistory(int orderId, int itemId) async {
    final response = await apiClient.dio.get('/orders/$orderId/items/$itemId/status-history');
    final api = ApiResponse<List<OrderItemStatusHistory>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>).map((entry) {
        final value = entry as Map<String, dynamic>;
        return OrderItemStatusHistory(
          id: _asInt(value['id']),
          orderItemId: _asInt(value['orderItemId']) ?? itemId,
          previousStatus: value['previousStatus'] as String?,
          newStatus: value['newStatus'] as String? ?? 'PENDING',
          comment: value['comment'] as String?,
          changedBy: _asInt(value['changedBy']),
          changedByName: value['changedByName'] as String?,
          changedAt: _asDate(value['changedAt']),
        );
      }).toList(),
    );
    _ensureSuccess(api.success, api.message, response);
    return api.data ?? const [];
  }

  Future<OrderModel> _save(Future<Response<dynamic>> request) async {
    final response = await request;
    final api = ApiResponse<OrderModel>.fromJson(
      response.data,
      (json) => OrderModel.fromJson(json as Map<String, dynamic>),
    );
    _ensureSuccess(api.success, api.message, response);
    if (api.data == null) throw Exception('No se recibieron datos de la orden');
    return api.data!;
  }

  @override
  Future<bool> delete(int id) async {
    final response = await apiClient.dio.delete('/orders/$id');
    final api = ApiResponse<dynamic>.fromJson(response.data, (json) => json);
    _ensureSuccess(api.success, api.message, response);
    return true;
  }

  void _ensureSuccess(
    bool success,
    String message,
    Response<dynamic> response,
  ) {
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: message,
      );
    }
  }
}

int? _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value');

DateTime? _asDate(dynamic value) =>
    value == null ? null : DateTime.tryParse('$value');
