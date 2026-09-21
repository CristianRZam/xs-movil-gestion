import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';
import 'package:app_movil_sistema/features/sale/domain/repositories/sale_repository.dart';
import 'package:dartz/dartz.dart';

class GetSalesUseCase { final SaleRepository repository; GetSalesUseCase(this.repository); Future<Either<Failure, List<Sale>>> call() => repository.getAll(); }
class CreateSaleUseCase { final SaleRepository repository; CreateSaleUseCase(this.repository); Future<Either<Failure, Sale>> call(Sale sale) => repository.create(sale); }
class GetCashSessionSalesSummaryUseCase { final SaleRepository repository; GetCashSessionSalesSummaryUseCase(this.repository); Future<Either<Failure, CashSessionSalesSummary>> call(int id) => repository.getCashSessionSummary(id); }
