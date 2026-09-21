import 'package:app_movil_sistema/features/sale/data/models/sale_model.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';
abstract class SaleRemoteDataSource { Future<List<SaleModel>> getAll(); Future<SaleModel> create(SaleModel sale); Future<CashSessionSalesSummary> getCashSessionSummary(int id); }
