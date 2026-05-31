import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardSaleAnalytic extends StatelessWidget {
  const DashboardSaleAnalytic({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sales = [
      SaleData('Enero', 12000),
      SaleData('Febrero', 10500),
      SaleData('Marzo', 14500),
      SaleData('Abril', 9800),
      SaleData('Mayo', 17000),
      SaleData('Junio', 15200),
      SaleData('Julio', 12000),
      SaleData('Agosto', 10500),
      SaleData('Septiembre', 14500),
      SaleData('Octubre', 9800),
      SaleData('Noviembre', 17000),
      SaleData('Diciembre', 15200),
    ];

    final maxSales = sales.map((s) => s.sales).reduce((a, b) => a > b ? a : b);
    final double maxY = ((maxSales / 1000).ceil() * 1000 + 5000).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // === Gráfico de barras con scroll y eje Y fijo ===
        Card(
          elevation: 6,
          color: isDark ? Colors.grey[900] : theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ventas Mensuales",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250, // 🔹 antes era 300, ahora más pequeño
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Eje Y fijo
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (maxY / 5000).ceil(),
                              (index) {
                            final value = index * 5000;
                            return Text(
                              "\$${value ~/ 1000}k",
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            );
                          },
                        ).reversed.toList(),
                      ),
                      const SizedBox(width: 8),
                      // Barras scroll
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: sales.length * 60, // 🔹 antes era 70, un poco más estrecho
                            child: BarChart(
                              BarChartData(
                                maxY: maxY,
                                gridData: FlGridData(
                                  show: true,
                                  horizontalInterval: 5000,
                                  drawHorizontalLine: true,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: isDark ? Colors.grey.shade700 : Colors.black12,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles:
                                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final i = value.toInt();
                                        if (i >= 0 && i < sales.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              sales[i].month.substring(0, 3),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  topTitles:
                                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles:
                                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: sales.asMap().entries.map(
                                      (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.sales,
                                        width: 20, // 🔹 antes 24, un poco más estrecho
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: LinearGradient(
                                          colors: [Colors.teal, Colors.greenAccent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // === Gráfico circular ===
        Card(
          elevation: 6,
          color: isDark ? Colors.grey[900] : theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Distribución de Ventas",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                      sections: sales.map((s) {
                        final color =
                        Colors.primaries[sales.indexOf(s) % Colors.primaries.length];
                        return PieChartSectionData(
                          value: s.sales,
                          title:
                          "${s.month.substring(0, 3)}\n\$${s.sales ~/ 1000}k",
                          radius: 90,
                          color: isDark ? color.shade700 : color.shade400,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SaleData {
  final String month;
  final double sales;
  SaleData(this.month, this.sales);
}
