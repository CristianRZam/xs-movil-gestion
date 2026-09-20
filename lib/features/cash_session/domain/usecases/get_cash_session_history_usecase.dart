import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/cash_session.dart';
import '../repositories/cash_session_repository.dart';

class GetCashSessionHistoryUseCase {

  final CashSessionRepository repository;

  GetCashSessionHistoryUseCase(this.repository);

  Future<Either<Failure, List<CashSession>>> call() {
    return repository.getHistory();
  }

}