import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:flutter/material.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final weeklyTotal = summary.weeklySales.fold<double>(0, (sum, day) => sum + day.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BusinessHealthCard(
          todaySales: summary.todaySales,
          weeklySales: weeklyTotal,
          orders: summary.todayOrders,
        ),
        const SizedBox(height: 16),
        Row(children: [const Icon(Icons.insights_rounded), const SizedBox(width: 8), Text('Indicadores de hoy', style: Theme.of(context).textTheme.titleMedium)]),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.65,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _MetricCard(icon: Icons.payments_rounded, title: 'Ventas', value: 'S/ ${summary.todaySales.toStringAsFixed(2)}'),
            _MetricCard(icon: Icons.receipt_long_rounded, title: 'Órdenes', value: '${summary.todayOrders}'),
            _MetricCard(icon: Icons.shopping_bag_rounded, title: 'Operaciones', value: '${summary.todaySalesCount}'),
            _MetricCard(icon: Icons.show_chart_rounded, title: 'Ticket promedio', value: 'S/ ${summary.averageSale.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }
}

class _BusinessHealthCard extends StatelessWidget {
  const _BusinessHealthCard({required this.todaySales, required this.weeklySales, required this.orders});
  final double todaySales;
  final double weeklySales;
  final int orders;
  @override
  Widget build(BuildContext context) { final colors = Theme.of(context).colorScheme; return Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.auto_graph_rounded, color: Colors.white), const SizedBox(width: 8), Text('Estado del negocio', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700))]),
            const SizedBox(height: 8),
            Text('S/ ${todaySales.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Ventas de hoy · $orders órdenes · S/ ${weeklySales.toStringAsFixed(2)} esta semana', style: TextStyle(color: Colors.white.withValues(alpha: .88))),
          ]),
        ),
      ); }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.title, required this.value});
  final IconData icon; final String title; final String value;
  @override
  Widget build(BuildContext context) { final colors = Theme.of(context).colorScheme; return Container(decoration: BoxDecoration(color: colors.surfaceContainerHighest.withValues(alpha: .55), borderRadius: BorderRadius.circular(18)), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: colors.onPrimaryContainer)), const Spacer(), Text(title, style: Theme.of(context).textTheme.bodySmall), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))]))); }
}
