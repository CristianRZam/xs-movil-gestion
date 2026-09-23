import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/order/data/datasources/order_remote_datasource.dart';
import 'package:app_movil_sistema/features/order/data/models/order_model.dart';
import 'package:app_movil_sistema/features/order/data/models/order_page_model.dart';
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
  Future<OrderModel> create(OrderModel order) =>
      _save(apiClient.dio.post('/orders', data: order.toJson()));

  @override
  Future<OrderModel> update(int id, OrderModel order) =>
      _save(apiClient.dio.put('/orders/$id', data: order.toJson()));

  @override
  Future<OrderModel> updateStatus(int id, String status) =>
      _save(apiClient.dio.put('/orders/$id/status', data: {'status': status}));

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
