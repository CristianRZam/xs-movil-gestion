import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../repositories/cash_session_repository.dart';

class ExistsOpenCashSessionUseCase {

  final CashSessionRepository repository;

  ExistsOpenCashSessionUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.existsOpenSession();
  }

}