import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale_page.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';
import 'package:app_movil_sistema/features/sale/domain/repositories/sale_repository.dart';
import 'package:dartz/dartz.dart';

class GetSalesUseCase {
  final SaleRepository repository;
  GetSalesUseCase(this.repository);
  Future<Either<Failure, SalePage>> call({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
  }) => repository.getAll(page: page, size: size, from: from, to: to);
}

class CreateSaleUseCase {
  final SaleRepository repository;
  CreateSaleUseCase(this.repository);
  Future<Either<Failure, Sale>> call(Sale sale) => repository.create(sale);
}

class CancelSaleUseCase {
  final SaleRepository repository;
  CancelSaleUseCase(this.repository);
  Future<Either<Failure, Sale>> call(int saleId, String reason) =>
      repository.cancel(saleId, reason);
}

class GetCashSessionSalesSummaryUseCase {
  final SaleRepository repository;
  GetCashSessionSalesSummaryUseCase(this.repository);
  Future<Either<Failure, CashSessionSalesSummary>> call(int id) =>
      repository.getCashSessionSummary(id);
}
