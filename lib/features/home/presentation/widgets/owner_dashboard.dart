import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:flutter/material.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final weeklyTotal = summary.weeklySales.fold<double>(
      0,
      (sum, day) => sum + day.total,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodSalesCard(
          periodSales: summary.todaySales,
          salesCount: summary.todaySalesCount,
          periodTotal: weeklyTotal,
        ),
        const SizedBox(height: 12),
        _SectionHeading(
          icon: Icons.date_range_outlined,
          title: 'Actividad del periodo',
          subtitle: 'Datos registrados en el rango seleccionado',
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 680;
            return GridView.count(
          crossAxisCount: isTablet ? 4 : 2,
          childAspectRatio: isTablet ? 1 : 1.06,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _MetricCard(
              icon: Icons.receipt_long_outlined,
              title: 'Ventas cobradas',
              value: '${summary.todaySalesCount}',
              help: 'Ventas completadas en el periodo',
            ),
            _MetricCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Ticket promedio',
              value: _money(summary.averageSale),
              help: 'Promedio por venta completada',
            ),
            _MetricCard(
              icon: Icons.restaurant_menu_outlined,
              title: 'Órdenes creadas',
              value: '${summary.todayOrders}',
              help: 'Pedidos registrados en el periodo',
            ),
            _MetricCard(
              icon: Icons.calendar_view_week_outlined,
              title: 'Total del periodo',
              value: _money(weeklyTotal),
              help: 'Ventas completadas del periodo',
            ),
          ],
            );
          },
        ),
      ],
    );
  }
}

class _PeriodSalesCard extends StatelessWidget {
  const _PeriodSalesCard({
    required this.periodSales,
    required this.salesCount,
    required this.periodTotal,
  });

  final double periodSales;
  final int salesCount;
  final double periodTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .22),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ventas cobradas del periodo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _PeriodBadge(label: '$salesCount ventas'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _money(periodSales),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Incluye solo ventas completadas del periodo seleccionado.',
            style: TextStyle(color: Colors.white.withValues(alpha: .84)),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withValues(alpha: .2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_view_week_outlined,
                color: Colors.white.withValues(alpha: .84),
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                'Total del periodo: ${_money(periodTotal)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodBadge extends StatelessWidget {
  const _PeriodBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .24)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.help,
  });

  final IconData icon;
  final String title;
  final String value;
  final String help;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? .22 : .12),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .035),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 23),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            help,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              height: 1.2,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: .7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

String _money(double amount) => 'S/ ${amount.toStringAsFixed(2)}';
