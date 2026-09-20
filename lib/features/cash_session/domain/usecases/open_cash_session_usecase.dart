import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/cash_session.dart';
import '../repositories/cash_session_repository.dart';

class OpenCashSessionUseCase {

  final CashSessionRepository repository;

  OpenCashSessionUseCase(this.repository);

  Future<Either<Failure, CashSession>> call(CashSession request,) {
    return repository.openSession(request);
  }

}