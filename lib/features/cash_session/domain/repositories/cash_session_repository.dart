import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session_close_request.dart';
import 'package:dartz/dartz.dart';

abstract class CashSessionRepository {

  Future<Either<Failure, CashSession>> openSession(CashSession request,);

  Future<Either<Failure, CashSession>> getCurrentSession();

  Future<Either<Failure, bool>> existsOpenSession();

  Future<Either<Failure, CashSession>> closeSession(CashSessionCloseRequest request,);

  Future<Either<Failure, List<CashSession>>> getHistory();
}