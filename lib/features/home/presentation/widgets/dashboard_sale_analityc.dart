import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/payment_method_style.dart';

class DashboardSaleAnalytic extends StatelessWidget {
  final DashboardSummary summary;
  const DashboardSaleAnalytic({super.key, required this.summary});

  static const colors = <Color>[
    Color(0xFF3478F6),
    Color(0xFF16A36A),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEF476F),
    Color(0xFF14B8A6),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Ventas últimos 7 días',
          subtitle: 'Importe de ventas completadas por día',
          child: _WeeklyChart(sales: summary.weeklySales),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Productos más vendidos',
          subtitle:
              'Top ${summary.topProducts.length.clamp(0, 10)} por unidades',
          child: _ProductsChart(products: summary.topProducts),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Métodos de pago más usados',
          subtitle: 'Distribución por importe cobrado',
          child: _PaymentMethods(methods: summary.paymentMethods),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<DailySale> sales;
  const _WeeklyChart({required this.sales});

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty)
      return const _EmptyChart(message: 'Aún no hay ventas en este periodo');
    final highest = sales
        .map((item) => item.total)
        .reduce((a, b) => a > b ? a : b);
    final maxY = highest == 0 ? 10.0 : highest * 1.25;
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0x172D3748)),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: maxY / 2,
                getTitlesWidget: (value, _) => Text(
                  'S/${value.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= sales.length)
                    return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _day(sales[index].date.weekday),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            sales.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: sales[index].total,
                  width: 19,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF47A3FF), Color(0xFF3468F6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _day(int day) =>
      const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][day - 1];
}

class _ProductsChart extends StatelessWidget {
  final List<TopProduct> products;
  const _ProductsChart({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty)
      return const _EmptyChart(message: 'Aún no hay productos vendidos');
    final max = products
        .map((item) => item.quantity)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    return Column(
      children: products.asMap().entries.map((entry) {
        final product = entry.value;
        final color = DashboardSaleAnalytic
            .colors[entry.key % DashboardSaleAnalytic.colors.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${product.quantity} und.',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: product.quantity / max,
                  minHeight: 9,
                  backgroundColor: color.withOpacity(.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentMethods extends StatelessWidget {
  final List<PaymentMethodUsage> methods;
  const _PaymentMethods({required this.methods});

  @override
  Widget build(BuildContext context) {
    if (methods.isEmpty)
      return const _EmptyChart(message: 'Aún no hay pagos registrados');
    final total = methods.fold<double>(0, (sum, item) => sum + item.total);
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 46,
              sectionsSpace: 3,
              sections: methods.map((item) {
                final color = PaymentMethodStyle.color(item.method);
                return PieChartSectionData(
                  value: item.total,
                  color: color,
                  radius: 56,
                  title: total == 0
                      ? ''
                      : '${(item.total / total * 100).round()}%',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...methods.map((item) {
          final color = PaymentMethodStyle.color(item.method);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _label(item.method),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'S/ ${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _label(String method) =>
      const {
        'CASH': 'Efectivo',
        'YAPE': 'Yape',
        'CARD': 'Tarjeta',
        'TRANSFER': 'Transferencia',
      }[method] ??
      method;
}

class _EmptyChart extends StatelessWidget {
  final String message;
  const _EmptyChart({required this.message});
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 140, child: Center(child: Text(message)));
}
