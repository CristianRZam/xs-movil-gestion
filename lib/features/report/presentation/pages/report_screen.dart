import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/features/report/data/report_downloader.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTimeRange _range = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now());
  String? _loading;
  final _reports = const [
    ('sales', 'Ventas', 'Ventas completadas y total cobrado', Icons.point_of_sale_rounded),
    ('products', 'Productos vendidos', 'Unidades e importe por producto', Icons.inventory_2_rounded),
    ('payments', 'Métodos de pago', 'Importe agrupado por medio de pago', Icons.account_balance_wallet_rounded),
    ('cash', 'Caja', 'Aperturas, cierres y diferencias', Icons.payments_rounded),
    ('orders', 'Órdenes', 'Órdenes creadas y su estado', Icons.receipt_long_rounded),
  ];

  Future<void> _selectRange() async {
    final selected = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now(), initialDateRange: _range, locale: const Locale('es'));
    if (selected != null) setState(() => _range = selected);
  }

  Future<void> _download(String type, String format) async {
    setState(() => _loading = '$type-$format');
    try {
      final path = await ReportDownloader(ApiClient()).download(type: type, format: format, start: _range.start, end: _range.end);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reporte guardado en $path')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo descargar el reporte: $error'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _loading = null); }
  }

  @override Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy');
    return Scaffold(appBar: const XsAppBar(title: 'Reportes'), endDrawer: const XsDrawer(), body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(.22)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.date_range_rounded, color: Theme.of(context).colorScheme.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Periodo del reporte', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), Text('Elige las fechas que deseas analizar', style: Theme.of(context).textTheme.bodySmall)]))]),
          const SizedBox(height: 16),
          InkWell(onTap: _selectRange, borderRadius: BorderRadius.circular(14), child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.45), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [Expanded(child: Text('${date.format(_range.start)}  —  ${date.format(_range.end)}', style: const TextStyle(fontWeight: FontWeight.w700))), Icon(Icons.edit_calendar_rounded, color: Theme.of(context).colorScheme.primary)]),
          )),
        ]),
      ),
      const SizedBox(height: 18),
      ..._reports.map((report) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(child: Icon(report.$4)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(report.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(report.$3)]))]), const SizedBox(height: 14), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _loading == null ? () => _download(report.$1, 'pdf') : null, icon: _loading == '${report.$1}-pdf' ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.picture_as_pdf_rounded), label: const Text('PDF'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: _loading == null ? () => _download(report.$1, 'excel') : null, icon: _loading == '${report.$1}-excel' ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.table_chart_rounded), label: const Text('Excel')))] )])))),
    ]));
  }
}
