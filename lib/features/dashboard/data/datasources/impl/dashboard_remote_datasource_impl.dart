import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:dio/dio.dart';

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;
  DashboardRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DashboardSummary> getSummary() async {
    final response = await apiClient.dio.get('/dashboard');
    final api = ApiResponse<DashboardSummary>.fromJson(response.data, (json) {
      final value = json as Map<String, dynamic>;
      final scope = value['scope'];
      if (scope != 'GLOBAL' && scope != 'PERSONAL') {
        throw const FormatException('Missing dashboard scope');
      }
      return DashboardSummary(
        isPersonal: scope == 'PERSONAL',
        summaryDate: value['summaryDate'] == null
            ? null
            : DateTime.parse(value['summaryDate'] as String),
        todaySalesCount: (value['todaySalesCount'] as num?)?.toInt() ?? 0,
        averageSale: (value['averageSale'] as num?)?.toDouble() ?? 0,
        todaySales: (value['todaySales'] as num?)?.toDouble() ?? 0,
        todayOrders: (value['todayOrders'] as num?)?.toInt() ?? 0,
        weeklySales: (value['weeklySales'] as List<dynamic>? ?? []).map((item) {
          final row = item as Map<String, dynamic>;
          return DailySale(
            date: DateTime.parse(row['date'] as String),
            total: (row['total'] as num?)?.toDouble() ?? 0,
          );
        }).toList(),
        topProducts: (value['topProducts'] as List<dynamic>? ?? []).map((item) {
          final row = item as Map<String, dynamic>;
          return TopProduct(
            productId: (row['productId'] as num?)?.toInt() ?? 0,
            productName: row['productName'] as String? ?? 'Producto',
            quantity: (row['quantity'] as num?)?.toInt() ?? 0,
          );
        }).toList(),
        paymentMethods: (value['paymentMethods'] as List<dynamic>? ?? []).map((
          item,
        ) {
          final row = item as Map<String, dynamic>;
          return PaymentMethodUsage(
            method: row['method'] as String? ?? 'OTRO',
            total: (row['total'] as num?)?.toDouble() ?? 0,
          );
        }).toList(),
      );
    });
    if (!api.success || api.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: api.message,
      );
    }
    return api.data!;
  }
}
