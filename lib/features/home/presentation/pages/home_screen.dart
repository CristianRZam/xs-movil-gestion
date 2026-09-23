import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:app_movil_sistema/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:app_movil_sistema/features/home/presentation/widgets/personal_dashboard.dart';
import 'package:app_movil_sistema/features/home/presentation/widgets/owner_dashboard.dart';
import 'package:app_movil_sistema/features/home/presentation/widgets/dashboard_sale_analityc.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-bottom-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DashboardSummary?> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<DashboardSummary?> _loadDashboard() async {
    final result = await getIt<GetDashboardSummaryUseCase>()();
    return result.fold((_) => null, (summary) {
      if (!summary.isPersonal &&
          !getIt<AccessControl>().allows(AppCapability.dashboard)) {
        return null;
      }
      return summary;
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final future = _loadDashboard();
    setState(() {
      _dashboardFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: const XsAppBar(title: 'Inicio', backIcon: false),
        endDrawer: const XsDrawer(),
        body: FutureBuilder<DashboardSummary?>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final summary = snapshot.data;
            if (summary == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 48),
                      const SizedBox(height: 12),
                      const Text('No se pudo cargar tu resumen'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            summary.isPersonal
                                ? 'Mi resumen de hoy'
                                : 'Resumen de tu negocio',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          onPressed: _refresh,
                          tooltip: 'Actualizar',
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (summary.isPersonal)
                      PersonalDashboard(summary: summary, onRefresh: _refresh)
                    else ...[
                      OwnerDashboard(summary: summary),
                      const SizedBox(height: 16),
                      DashboardSaleAnalytic(summary: summary),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const XsBottomBar(),
      ),
    );
  }
}
