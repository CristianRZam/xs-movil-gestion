import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:app_movil_sistema/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository repository;
  GetDashboardSummaryUseCase(this.repository);

  Future<Either<Failure, DashboardSummary>> call() => repository.getSummary();
}
