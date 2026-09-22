import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummary> getSummary();
}
