import 'package:app_movil_sistema/features/sale/data/models/sale_model.dart';
import 'package:app_movil_sistema/features/sale/data/models/sale_page_model.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';

abstract class SaleRemoteDataSource {
  Future<SalePageModel> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
  });
  Future<SaleModel> create(SaleModel sale);
  Future<SaleModel> cancel(int saleId, String reason);
  Future<CashSessionSalesSummary> getCashSessionSummary(int id);
}
