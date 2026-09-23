import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale_page.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';
import 'package:dartz/dartz.dart';

abstract class SaleRepository {
  Future<Either<Failure, SalePage>> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
  });
  Future<Either<Failure, Sale>> create(Sale sale);
  Future<Either<Failure, Sale>> cancel(int saleId, String reason);
  Future<Either<Failure, CashSessionSalesSummary>> getCashSessionSummary(
    int cashSessionId,
  );
}
