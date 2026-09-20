import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/cash_session.dart';
import '../entities/cash_session_close_request.dart';
import '../repositories/cash_session_repository.dart';

class CloseCashSessionUseCase {

  final CashSessionRepository repository;

  CloseCashSessionUseCase(this.repository);

  Future<Either<Failure, CashSession>> call(CashSessionCloseRequest request,) {
    return repository.closeSession(request);
  }

}