import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dashboard_card.dart';

class PersonalDashboard extends StatelessWidget {
  const PersonalDashboard({
    super.key,
    required this.summary,
    required this.onRefresh,
  });

  final DashboardSummary summary;
  final Future<void> Function() onRefresh;

  String _money(double amount) => 'S/ ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardCard(
        icon: Icons.payments_rounded,
        title: 'Mis ventas de hoy',
        value: _money(summary.todaySales),
        subtitle: 'Importe de mis ventas completadas',
      ),
      DashboardCard(
        icon: Icons.receipt_long_rounded,
        title: 'Ventas realizadas',
        value: '${summary.todaySalesCount}',
        subtitle: 'Registradas por mí hoy',
      ),
      DashboardCard(
        icon: Icons.calculate_outlined,
        title: 'Promedio por venta',
        value: _money(summary.averageSale),
        subtitle: 'Solo mis ventas completadas de hoy',
      ),
      DashboardCard(
        icon: Icons.shopping_bag_outlined,
        title: 'Mis órdenes de hoy',
        value: '${summary.todayOrders}',
        subtitle: 'Creadas por mí, en cualquier estado',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          summary.summaryDate == null
              ? 'Tu actividad del día'
              : 'Tu actividad del ${DateFormat('dd/MM/yyyy').format(summary.summaryDate!)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text(
          'Solo se incluyen las operaciones registradas con tu usuario.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final card in cards) SizedBox(width: width, child: card),
              ],
            );
          },
        ),
        if (summary.todaySalesCount == 0) ...[
          const SizedBox(height: 16),
          const Text('Todavía no has registrado ventas hoy.'),
        ],
        if (summary.topProducts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Mis productos más vendidos hoy',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final product in summary.topProducts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(product.productName),
              subtitle: Text('${product.quantity} unidades'),
            ),
        ],
        if (summary.paymentMethods.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Cobros de mis ventas de hoy',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final payment in summary.paymentMethods)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(_paymentLabel(payment.method)),
              subtitle: Text(_money(payment.total)),
            ),
        ],
        const SizedBox(height: 24),
        Text('Operaciones', style: Theme.of(context).textTheme.titleMedium),
        for (final entry in const {
          AppRoutes.product: 'Consultar productos',
          AppRoutes.orders: 'Órdenes',
          AppRoutes.sales: 'Registrar venta',
          AppRoutes.cashSession: 'Caja',
        }.entries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(entry.value),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.pushNamed(context, entry.key);
              if (context.mounted) {
                await onRefresh();
              }
            },
          ),
      ],
    );
  }

  String _paymentLabel(String method) => switch (method) {
    'CASH' => 'Efectivo',
    'CARD' => 'Tarjeta',
    'TRANSFER' => 'Transferencia',
    'YAPE' => 'Yape',
    'PLIN' => 'Plin',
    _ => method,
  };
}
