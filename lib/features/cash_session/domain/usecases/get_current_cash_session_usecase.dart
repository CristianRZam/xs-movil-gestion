import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/cash_session.dart';
import '../repositories/cash_session_repository.dart';

class GetCurrentCashSessionUseCase {

  final CashSessionRepository repository;

  GetCurrentCashSessionUseCase(this.repository);

  Future<Either<Failure, CashSession>> call() {
    return repository.getCurrentSession();
  }

}