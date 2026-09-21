import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';
import 'package:dartz/dartz.dart';

abstract class SaleRepository {
  Future<Either<Failure, List<Sale>>> getAll();
  Future<Either<Failure, Sale>> create(Sale sale);
  Future<Either<Failure, CashSessionSalesSummary>> getCashSessionSummary(int cashSessionId);
}
