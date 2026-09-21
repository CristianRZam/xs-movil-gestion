import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/sale/data/datasources/sale_remote_datasource.dart';
import 'package:app_movil_sistema/features/sale/data/models/sale_model.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';
import 'package:app_movil_sistema/features/sale/domain/repositories/sale_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleRemoteDataSource remote; SaleRepositoryImpl(this.remote);
  @override Future<Either<Failure, List<Sale>>> getAll() => _handle(() => remote.getAll());
  @override Future<Either<Failure, Sale>> create(Sale sale) => _handle(() => remote.create(SaleModel.fromEntity(sale)));
  @override Future<Either<Failure, CashSessionSalesSummary>> getCashSessionSummary(int id) => _handle(() => remote.getCashSessionSummary(id));
  Future<Either<Failure, T>> _handle<T>(Future<T> Function() action) async { try { return Right(await action()); } on DioException catch (e) { return Left(FailureMapper.fromDioException(e)); } catch (_) { return Left(UnexpectedFailure()); } }
}
