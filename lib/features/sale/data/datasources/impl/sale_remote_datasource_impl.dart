import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/sale/data/datasources/sale_remote_datasource.dart';
import 'package:app_movil_sistema/features/sale/data/models/sale_model.dart';
import 'package:app_movil_sistema/features/sale/data/models/sale_page_model.dart';
import 'package:dio/dio.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final ApiClient apiClient;
  SaleRemoteDataSourceImpl(this.apiClient);
  @override
  Future<SalePageModel> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await apiClient.dio.get(
      '/sales',
      queryParameters: {
        'page': page,
        'size': size,
        if (from != null) 'fromDate': _date(from),
        if (to != null) 'toDate': _date(to),
      },
    );
    final api = ApiResponse<SalePageModel>.fromJson(
      response.data,
      (json) => SalePageModel.fromJson(json as Map<String, dynamic>),
    );
    _success(api.success, api.message, response);
    if (api.data == null) throw Exception('No se recibieron ventas');
    return api.data!;
  }

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  @override
  Future<SaleModel> create(SaleModel sale) async {
    final response = await apiClient.dio.post('/sales', data: sale.toJson());
    final api = ApiResponse<SaleModel>.fromJson(
      response.data,
      (json) => SaleModel.fromJson(json as Map<String, dynamic>),
    );
    _success(api.success, api.message, response);
    if (api.data == null) throw Exception('No se recibió la venta');
    return api.data!;
  }

  @override
  Future<SaleModel> cancel(int saleId, String reason) async {
    final response = await apiClient.dio.post('/sales/$saleId/cancel', data: {'reason': reason});
    final api = ApiResponse<SaleModel>.fromJson(
      response.data,
      (json) => SaleModel.fromJson(json as Map<String, dynamic>),
    );
    _success(api.success, api.message, response);
    if (api.data == null) throw Exception('No se recibió la venta anulada');
    return api.data!;
  }

  @override
  Future<CashSessionSalesSummary> getCashSessionSummary(int id) async {
    final response = await apiClient.dio.get('/sales/cash-session/$id');
    final api = ApiResponse<CashSessionSalesSummary>.fromJson(response.data, (
      json,
    ) {
      final value = json as Map<String, dynamic>;
      return CashSessionSalesSummary(
        cashSessionId: (value['cashSessionId'] as num).toInt(),
        totalSold: (value['totalSold'] as num).toDouble(),
        paymentMethods: (value['paymentMethods'] as List<dynamic>? ?? []).map((
          e,
        ) {
          final item = e as Map<String, dynamic>;
          return PaymentMethodTotal(
            paymentMethod: item['paymentMethod'] as String,
            total: (item['total'] as num).toDouble(),
          );
        }).toList(),
        sales: (value['sales'] as List<dynamic>? ?? [])
            .map((e) => SaleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    });
    _success(api.success, api.message, response);
    if (api.data == null) throw Exception('No se recibió el resumen');
    return api.data!;
  }

  void _success(bool success, String message, Response response) {
    if (!success)
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: message,
      );
  }
}
