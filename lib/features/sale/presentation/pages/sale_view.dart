import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_lookup.dart';
import 'package:app_movil_sistema/features/product/data/services/product_lookup_service.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/usecases/sale_usecases.dart';
import 'package:app_movil_sistema/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-filter-button.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-async-lookup-field.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SaleView extends StatelessWidget {
  final Order? order;

  const SaleView({super.key, this.order});

  bool get _canCreateSale =>
      getIt<AccessControl>().allows(AppCapability.createSales);

  bool get _isOrderReadyToCharge {
    final activeItems = order?.items
            .where((item) => item.status != 'CANCELLED')
            .toList() ??
        const [];
    return activeItems.isNotEmpty &&
        activeItems.every((item) => item.status == 'SERVED');
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<SaleBloc, SaleState>(
    listenWhen: (previous, current) =>
        (previous.error != current.error && current.error != null) ||
        (!previous.saved && current.saved) ||
        (!previous.cancelled && current.cancelled),
    listener: (context, state) {
      if (state.error != null) {
        // Un 403 ya muestra el toast global de autorización. Cuando la
        // respuesta del servidor no trae detalle, el mapper usa este texto
        // genérico; no debe aparecer como un segundo mensaje confuso.
        if (state.error != 'Error desconocido') {
          FlashMessage.show(
            context,
            type: FlashMessageType.error,
            title: 'No se pudo registrar la venta',
            message: state.error!,
          );
        }
        context.read<SaleBloc>().add(const ClearSaleMessage());
      }
      if (state.saved) {
        Navigator.of(context, rootNavigator: true).maybePop();
        FlashMessage.show(
          context,
          type: FlashMessageType.success,
          title: 'Venta registrada',
          message: 'Venta registrada correctamente',
        );
        context.read<SaleBloc>().add(const ClearSaleMessage());
      }
      if (state.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.cancellationRestoredOrder
                  ? 'Venta anulada. El stock fue restaurado y la orden quedó lista para cobrar o cancelar.'
                  : 'Venta anulada y stock restaurado correctamente.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        context.read<SaleBloc>().add(const ClearSaleMessage());
      }
    },
    builder: (context, state) => Scaffold(
      appBar: XsAppBar(
        title: order == null ? 'Ventas' : 'Cobrar',
        backIcon: false,
      ),
      endDrawer: const XsDrawer(),
      floatingActionButton: _canCreateSale
          ? FloatingActionButton.extended(
              onPressed: state.cashOpen == true &&
                      (order == null || _isOrderReadyToCharge)
                  ? () => _openSaleForm(context, state.products, order: order)
                  : null,
              icon: const Icon(Icons.point_of_sale),
              label: Text(order == null ? 'Nueva venta' : 'Cobrar orden'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.cashOpen != true)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Abra una sesión de caja antes de registrar ventas.',
                ),
              ),
            ),
          if (order != null)
            Card(
              child: ListTile(
                title: Text('Orden ${order!.orderNumber}'),
                subtitle: Text(
                  _isOrderReadyToCharge
                      ? 'Todos los productos activos fueron servidos y estan listos para cobrar.'
                      : 'Falta servir productos activos antes de poder cobrar esta orden.',
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SaleFilterSummary(state: state)),
              const SizedBox(width: 10),
              XsFilterButton(onPressed: () => _showSaleFilters(context, state)),
            ],
          ),
          const SizedBox(height: 12),
          if (state.sales.isEmpty && state.status != SaleStatus.loading)
            const Padding(
              padding: EdgeInsets.only(top: 32, bottom: 20),
              child: Center(
                child: Text('No se encontraron ventas en este período.'),
              ),
            ),
          ...state.sales.map((sale) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SaleListCard(
                  sale: sale,
                  onTap: () => _openSaleDetail(context, sale, state.products),
                ),
              )),
          if (state.hasMoreSales || state.isLoadingMoreSales)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: state.isLoadingMoreSales
                      ? null
                      : () =>
                            context.read<SaleBloc>().add(const LoadMoreSales()),
                  icon: state.isLoadingMoreSales
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  label: Text(
                    state.isLoadingMoreSales ? 'Cargando...' : 'Ver más ventas',
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _SaleListCard extends StatelessWidget {
  const _SaleListCard({required this.sale, required this.onTap});

  final Sale sale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCancelled = sale.status == 'CANCELLED';
    final accent = isCancelled ? scheme.error : AppColors.primary;
    final itemCount = sale.itemCount ?? sale.items.length;
    final quantity = sale.totalQuantity;
    final dateLabel = sale.createdAt == null
        ? 'Fecha no disponible'
        : DateFormat('dd/MM · HH:mm').format(sale.createdAt!);
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(sale.saleNumber, style: const TextStyle(fontWeight: FontWeight.w800))),
                _SaleStatusBadge(status: sale.status),
              ]),
              const SizedBox(height: 11),
              Row(children: [
                Icon(Icons.schedule_outlined, size: 15, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(dateLabel, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 10),
                Icon(Icons.person_outline_rounded, size: 15, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(child: Text(sale.createdByName?.trim().isNotEmpty == true ? sale.createdByName!.trim() : 'Vendedor no disponible', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)),
              ]),
              if (sale.orderNumber?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 9),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 3, top: 3, bottom: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.receipt_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text('Orden ${sale.orderNumber!.trim()}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                      IconButton(
                        tooltip: 'Copiar número de orden',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        padding: const EdgeInsets.all(4),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: sale.orderNumber!.trim()));
                          if (!context.mounted) return;
                          FlashMessage.show(context, type: FlashMessageType.success, title: 'Número copiado', message: 'El número de orden fue copiado al portapapeles.');
                        },
                        icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
                      ),
                    ]),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sale.payments.map((payment) => _PaymentMethodChip(payment: payment)).toList(),
              ),
              const SizedBox(height: 11),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(child: Text('$itemCount producto(s)${quantity == null ? '' : ' · ${_quantityLabel(quantity)} und.'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                  Text('S/ ${sale.total.toStringAsFixed(2)}', style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 16)),
                ]),
              ),
              if (sale.notes?.trim().isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(sale.notes!.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({required this.payment});
  final SalePayment payment;

  @override
  Widget build(BuildContext context) {
    final visual = _paymentVisual(payment.paymentMethod);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: visual.$2.withValues(alpha: .11), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(visual.$1, size: 14, color: visual.$2),
        const SizedBox(width: 4),
        Text(visual.$3, style: TextStyle(color: visual.$2, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

(IconData, Color, String) _paymentVisual(String method) => switch (method) {
  'CASH' => (Icons.payments_outlined, const Color(0xFF16803C), 'Efectivo'),
  'YAPE' => (Icons.phone_android_rounded, const Color(0xFF6A1B9A), 'Yape'),
  'PLIN' => (Icons.phone_android_rounded, const Color(0xFF0089A8), 'Plin'),
  'CARD' => (Icons.credit_card_rounded, const Color(0xFF2563EB), 'Tarjeta'),
  'TRANSFER' => (Icons.account_balance_outlined, const Color(0xFF0F766E), 'Transferencia'),
  _ => (Icons.account_balance_wallet_outlined, AppColors.primary, _paymentLabel(method)),
};

String _quantityLabel(double value) => value % 1 == 0
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

class _SaleFilterSummary extends StatelessWidget {
  const _SaleFilterSummary({required this.state});
  final SaleState state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state.dateFilter) {
      SaleDateFilter.today => 'Hoy',
      SaleDateFilter.week => 'Esta semana',
      SaleDateFilter.month => 'Este mes',
      SaleDateFilter.custom => 'Periodo personalizado',
      _ => 'Todas las ventas',
    };
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Icon(Icons.tune_rounded, size: 19),
        const SizedBox(width: 8),
        Expanded(child: Text(state.saleStatus == null && state.saleProductId == null ? label : '$label · Filtros activos', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

Future<void> _showSaleFilters(BuildContext context, SaleState state) async {
  var filter = state.dateFilter;
  var status = state.saleStatus;
  ProductLookup? product = state.saleProductId == null
      ? null
      : ProductLookup(
          id: state.saleProductId!,
          name: state.saleProductName ?? 'Producto seleccionado',
          code: '',
          active: true,
          deleted: false,
        );
  var from = state.fromDate;
  var to = state.toDate;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (_, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Filtrar ventas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: SaleDateFilter.values.map((value) => ChoiceChip(label: Text(_saleFilterLabel(value)), selected: filter == value, onSelected: (_) async {
              if (value == SaleDateFilter.custom) {
                final now = DateUtils.dateOnly(DateTime.now());
                final range = await showDateRangePicker(
                  context: sheetContext,
                  firstDate: DateTime(2020),
                  lastDate: now,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  initialDateRange: from != null && to != null
                      ? DateTimeRange(start: from!, end: to!)
                      : null,
                );
                if (range == null) return;
                setSheetState(() { filter = value; from = DateUtils.dateOnly(range.start); to = DateUtils.dateOnly(range.end); });
              } else {
                final now = DateUtils.dateOnly(DateTime.now());
                setSheetState(() { filter = value; from = value == SaleDateFilter.today ? now : value == SaleDateFilter.week ? now.subtract(Duration(days: now.weekday - 1)) : value == SaleDateFilter.month ? DateTime(now.year, now.month) : null; to = value == SaleDateFilter.all ? null : now; });
              }
            })).toList()),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(value: status, decoration: const InputDecoration(labelText: 'Estado'), items: const [DropdownMenuItem(value: null, child: Text('Todos los estados')), DropdownMenuItem(value: 'COMPLETED', child: Text('Completada')), DropdownMenuItem(value: 'CANCELLED', child: Text('Anulada'))], onChanged: (value) => setSheetState(() => status = value)),
            const SizedBox(height: 12),
            XsAsyncLookupField<ProductLookup>(
              selected: product,
              labelText: 'Producto',
              hintText: 'Escribe al menos 2 letras',
              search: getIt<ProductLookupService>().search,
              itemLabel: (item) {
                final label = item.code.isEmpty ? item.name : '${item.name} (${item.code})';
                if (item.deleted) return '$label · Eliminado';
                return '$label${item.active ? '' : ' · Inactivo'}';
              },
              onSelected: (item) => setSheetState(() => product = item),
              onCleared: () => setSheetState(() => product = null),
            ),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: OutlinedButton(onPressed: () { context.read<SaleBloc>().add(const LoadSales()); Navigator.pop(sheetContext); }, child: const Text('Limpiar'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: () { context.read<SaleBloc>().add(LoadSales(filter: filter, fromDate: from, toDate: to, status: status, productId: product?.id, productName: product?.name)); Navigator.pop(sheetContext); }, child: const Text('Aplicar filtros')))]),
          ]),
        ),
      ),
    ),
  );
}

String _saleFilterLabel(SaleDateFilter filter) => switch (filter) { SaleDateFilter.all => 'Todos', SaleDateFilter.today => 'Hoy', SaleDateFilter.week => 'Semana', SaleDateFilter.month => 'Mes', SaleDateFilter.custom => 'Personalizado' };

class _SaleDateFilters extends StatelessWidget {
  const _SaleDateFilters({required this.state});
  final SaleState state;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, right: 6),
            child: Icon(Icons.calendar_month_outlined, size: 18),
          ),
          _chip(context, 'Todos', SaleDateFilter.all),
          _chip(context, 'Hoy', SaleDateFilter.today),
          _chip(context, 'Esta semana', SaleDateFilter.week),
          _chip(context, 'Este mes', SaleDateFilter.month),
          _chip(context, 'Personalizado', SaleDateFilter.custom),
        ],
      ),
    ),
  );

  Widget _chip(BuildContext context, String label, SaleDateFilter filter) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: state.dateFilter == filter,
          onSelected: (_) => _select(context, filter),
        ),
      );

  Future<void> _select(BuildContext context, SaleDateFilter filter) async {
    final now = DateUtils.dateOnly(DateTime.now());
    DateTime? from;
    DateTime? to;
    if (filter == SaleDateFilter.today) {
      from = now;
      to = now;
    } else if (filter == SaleDateFilter.week) {
      from = now.subtract(Duration(days: now.weekday - 1));
      to = now;
    } else if (filter == SaleDateFilter.month) {
      from = DateTime(now.year, now.month);
      to = now;
    } else if (filter == SaleDateFilter.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: now,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDateRange: state.fromDate != null && state.toDate != null
            ? DateTimeRange(start: state.fromDate!, end: state.toDate!)
            : null,
      );
      if (picked == null || !context.mounted) return;
      from = DateUtils.dateOnly(picked.start);
      to = DateUtils.dateOnly(picked.end);
    }
    if (!context.mounted) return;
    context.read<SaleBloc>().add(
      LoadSales(filter: filter, fromDate: from, toDate: to),
    );
  }
}

Future<void> _openSaleDetail(
  BuildContext context,
  Sale sale,
  List<Product> products,
) async {
  if (sale.id == null) return;
  final result = await getIt<GetSaleByIdUseCase>()(sale.id!);
  if (!context.mounted) return;
  result.fold(
    (failure) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    ),
    (detail) => _showSaleDetail(context, detail, products),
  );
}

void _showSaleDetail(BuildContext context, Sale sale, List<Product> products) {
  String productName(int id) {
    for (final product in products) {
      if (product.id == id) return product.name;
    }
    return 'Producto #$id';
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .65,
        maxChildSize: .9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              sale.saleNumber,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Estado: ${_saleStatusLabel(sale.status)}'),
            const SizedBox(height: 4),
            Text(
              'Registrada por: ${sale.createdByName ?? 'Usuario no disponible'}',
            ),
            if (sale.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _SaleNotesCard(notes: sale.notes!.trim()),
            ],
            if (sale.cancellationReason != null) ...[
              const SizedBox(height: 12),
              _SaleCancellationCard(sale: sale),
            ],
            const Divider(height: 28),
            const Text(
              'Productos consumidos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...sale.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(productName(item.productId)),
                subtitle: Text(
                  '${item.quantity.toInt()} × S/ ${item.unitPrice.toStringAsFixed(2)}',
                ),
                trailing: Text('S/ ${item.subtotal.toStringAsFixed(2)}'),
              ),
            ),
            const Divider(height: 28),
            const Text(
              'Formas de pago',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...sale.payments.map(
              (payment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined),
                title: Text(_paymentLabel(payment.paymentMethod)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (payment.reference != null)
                      Text('Referencia: ${payment.reference}'),
                    if (payment.receivedAmount != null)
                      Text(
                        'Recibido: S/ ${payment.receivedAmount!.toStringAsFixed(2)}',
                      ),
                    if (payment.changeAmount != null &&
                        payment.changeAmount! > 0)
                      Text(
                        'Vuelto: S/ ${payment.changeAmount!.toStringAsFixed(2)}',
                      ),
                  ],
                ),
                trailing: Text('S/ ${payment.amount.toStringAsFixed(2)}'),
              ),
            ),
            if (sale.discount > 0) ...[
              const Divider(height: 28),
              _SaleAmountRow(
                label: 'Subtotal',
                amount: sale.total + sale.discount,
              ),
              const SizedBox(height: 6),
              _SaleAmountRow(
                label: 'Descuento aplicado',
                amount: -sale.discount,
                highlighted: true,
              ),
            ],
            const Divider(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: S/ ${sale.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (sale.id != null &&
                sale.status == 'COMPLETED' &&
                getIt<AccessControl>().allows(AppCapability.cancelSales)) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(sheetContext).colorScheme.error,
                  foregroundColor: Theme.of(sheetContext).colorScheme.onError,
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Anular venta'),
                onPressed: () async {
                  final reason = await _requestCancellationReason(
                    sheetContext,
                    sale.saleNumber,
                  );
                  if (reason == null || !context.mounted) return;
                  Navigator.of(sheetContext).pop();
                  context.read<SaleBloc>().add(
                    CancelSale(
                      sale.id!,
                      reason,
                      restoredOrder: sale.orderId != null,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _SaleStatusBadge extends StatelessWidget {
  const _SaleStatusBadge({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelled = status == 'CANCELLED';
    final isCompleted = status == null || status == 'COMPLETED';
    final foreground = isCancelled
        ? (theme.brightness == Brightness.dark
              ? const Color(0xFFFFB4AB)
              : const Color(0xFFB42318))
        : (isCompleted
              ? (theme.brightness == Brightness.dark
                    ? const Color(0xFF9FF5C7)
                    : const Color(0xFF087443))
              : theme.colorScheme.onSurfaceVariant);
    final background = isCancelled
        ? (theme.brightness == Brightness.dark
              ? const Color(0xFF3B1E22)
              : const Color(0xFFFFF4F4))
        : (isCompleted
              ? (theme.brightness == Brightness.dark
                    ? const Color(0xFF173B2B)
                    : const Color(0xFFEAF8F0))
              : theme.colorScheme.surfaceContainerHighest);
    final label = isCancelled
        ? 'Anulada'
        : (isCompleted ? 'Completada' : status!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<String?> _requestCancellationReason(
  BuildContext context,
  String saleNumber,
) async {
  final formKey = GlobalKey<FormState>();
  var reason = '';
  final value = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Anular venta'),
      content: Form(
        key: formKey,
        child: TextFormField(
          initialValue: reason,
          autofocus: true,
          maxLength: 500,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Motivo de anulación',
            hintText: 'Indica por qué se anula $saleNumber',
          ),
          validator: (text) => text == null || text.trim().isEmpty
              ? 'El motivo es obligatorio.'
              : null,
          onChanged: (value) => reason = value,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Volver'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(dialogContext).pop(reason.trim());
            }
          },
          child: const Text('Confirmar anulación'),
        ),
      ],
    ),
  );
  return value;
}

class _SaleAmountRow extends StatelessWidget {
  const _SaleAmountRow({
    required this.label,
    required this.amount,
    this.highlighted = false,
  });

  final String label;
  final double amount;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? Theme.of(context).colorScheme.primary : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        Text(
          '${amount < 0 ? '-' : ''}S/ ${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SaleNotesCard extends StatelessWidget {
  const _SaleNotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note_alt_outlined,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota de venta',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleCancellationCard extends StatelessWidget {
  const _SaleCancellationCard({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF3B1E22)
        : const Color(0xFFFFF4F4);
    final accent = isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB42318);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cancel_outlined, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Venta anulada',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Motivo: ${sale.cancellationReason}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (sale.cancelledByName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Anulada por: ${sale.cancelledByName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _paymentLabel(String method) => switch (method) {
  'CASH' => 'Efectivo',
  'YAPE' => 'Yape',
  'PLIN' => 'Plin',
  'CARD' => 'Tarjeta',
  'TRANSFER' => 'Transferencia',
  _ => method,
};

String _saleStatusLabel(String? status) => switch (status) {
  'CANCELLED' => 'Anulada',
  'COMPLETED' => 'Completada',
  null => 'Completada',
  _ => status,
};

Future<void> _openSaleForm(
  BuildContext context,
  List<Product> products, {
  Order? order,
}) async {
  if (!getIt<AccessControl>().allows(AppCapability.createSales)) return;
  final navigator = Navigator.of(context, rootNavigator: true);
  await navigator.push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<SaleBloc>(),
        child: _SaleForm(products: products, order: order),
      ),
    ),
  );
}

class _SaleForm extends StatefulWidget {
  final List<Product> products;
  final Order? order;

  const _SaleForm({required this.products, this.order});

  @override
  State<_SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<_SaleForm> {
  final _formKey = GlobalKey<FormState>();
  final _items = <SaleItem>[];
  final _payments = <_PaymentDraft>[];
  final _productsById = <int, Product>{};
  final _discount = TextEditingController();
  final _notes = TextEditingController();
  bool _showCheckout = false;

  @override
  void initState() {
    super.initState();
    _productsById.addEntries(
      widget.products.map((product) => MapEntry(product.id, product)),
    );
    _payments.add(_PaymentDraft());
    final order = widget.order;
    if (order != null) {
      for (final item in order.items.where(
        (item) => item.status != 'CANCELLED' &&
            !order.nonChargeableItemIds.contains(item.id),
      )) {
        final index = _items.indexWhere((saleItem) =>
            saleItem.productId == item.productId &&
            saleItem.unitPrice == item.unitPrice &&
            saleItem.discount == 0);
        if (index < 0) {
          _items.add(SaleItem(
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ));
        } else {
          final saleItem = _items[index];
          _items[index] = SaleItem(
            productId: saleItem.productId,
            productName: saleItem.productName,
            quantity: saleItem.quantity + item.quantity,
            unitPrice: saleItem.unitPrice,
          );
        }
      }
    }
  }

  double get _subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.subtotal);
  double get _discountAmount => double.tryParse(_discount.text) ?? 0;
  double get _incidentDiscount {
    final order = widget.order;
    if (order == null) return 0;
    final noChargeAmount = order.items
        .where((item) => order.nonChargeableItemIds.contains(item.id))
        .fold<double>(0, (sum, item) => sum + item.subtotal);
    return (order.incidentDiscount - noChargeAmount).clamp(0, double.infinity);
  }
  double get _totalDiscount => _discountAmount + _incidentDiscount;
  double get _total => (_subtotal - _totalDiscount).clamp(0, double.infinity);
  double get _paid => _payments.fold<double>(
    0,
    (sum, payment) => sum + (double.tryParse(payment.amount.text) ?? 0),
  );

  @override
  void dispose() {
    for (final payment in _payments) {
      payment.dispose();
    }
    _discount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order == null && !_showCheckout) {
      return _buildSaleCatalog(context);
    }
    return _buildCheckout(context);
  }

  Widget _buildCheckout(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.order == null ? 'Nueva venta directa' : 'Cobrar orden'),
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.order != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Orden en cobro: ${widget.order!.orderNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _discount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Descuento de venta (S/)',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                validator: (value) => _totalDiscount > _subtotal
                    ? 'Los descuentos no pueden superar el subtotal'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              if (_incidentDiscount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Descuento por incidencias: -S/ ${_incidentDiscount.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Nota de venta (opcional)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 12),
              _PaymentSummary(
                subtotal: _subtotal,
                discount: _totalDiscount,
                total: _total,
                paid: _paid,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  const SizedBox(width: 8),
                  const Text(
                    'Productos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                ],
              ),
              if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Agregue al menos un producto.'),
                ),
              ..._items.asMap().entries.map(_itemTile),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Formas de pago',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Puedes combinar varios medios para completar el cobro.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              ..._payments.asMap().entries.map(
                (entry) => _PaymentRow(
                  draft: entry.value,
                  removable: _payments.length > 1,
                  onChanged: () => setState(() {}),
                  onRemove: () => setState(() {
                    entry.value.dispose();
                    _payments.removeAt(entry.key);
                  }),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _payments.add(_PaymentDraft())),
                icon: const Icon(Icons.add_card),
                label: const Text('Agregar método de pago'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.order == null
                      ? () => setState(() => _showCheckout = false)
                      : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _items.isEmpty ? null : _save,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Confirmar cobro'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildSaleCatalog(BuildContext context) => BlocBuilder<SaleBloc, SaleState>(
    builder: (context, state) {
      for (final product in state.products) {
        _productsById[product.id] = product;
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nueva venta'),
          actions: [
            IconButton(
              tooltip: 'Ver carrito',
              onPressed: _showCart,
              icon: Badge(
                isLabelVisible: _items.isNotEmpty,
                label: Text('${_items.length}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ProductSelectorSheet(
                  products: state.products,
                  categories: state.productCategories,
                  selectedCategoryIds: state.selectedProductCategoryIds,
                  availableOnly: state.availableProductsOnly,
                  searchQuery: state.productSearchQuery,
                  hasMore: state.hasMoreProducts,
                  isLoadingMore: state.isLoadingMoreProducts,
                  onLoadMore: () => context.read<SaleBloc>().add(
                    const LoadMoreSaleProducts(),
                  ),
                  onSearchChanged: (query) => context.read<SaleBloc>().add(
                    SearchSaleProducts(query),
                  ),
                  onFiltersChanged: (categoryIds, availableOnly) => context
                      .read<SaleBloc>()
                      .add(
                        FilterSaleProducts(
                          categoryIds: categoryIds,
                          availableOnly: availableOnly,
                        ),
                      ),
                  onProductSelected: _addProductToCart,
                ),
              ),
              _SaleCartBar(
                itemCount: _items.length,
                total: _subtotal,
                onOpenCart: _showCart,
                onCheckout: _items.isEmpty
                    ? null
                    : () => setState(() => _showCheckout = true),
              ),
            ],
          ),
        ),
      );
    },
  );

  void _addProductToCart(Product product) {
    if (product.availableStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El producto no tiene stock disponible.')),
      );
      return;
    }
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );
    if (existingIndex >= 0 &&
        _items[existingIndex].quantity >= product.availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo hay ${product.availableStock} unidad(es) disponible(s).',
          ),
        ),
      );
      return;
    }
    setState(() {
      _productsById[product.id] = product;
      if (existingIndex >= 0) {
        final item = _items[existingIndex];
        _items[existingIndex] = SaleItem(
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity + 1,
          unitPrice: item.unitPrice,
          discount: item.discount,
        );
      } else {
        _items.add(
          SaleItem(
            productId: product.id,
            productName: product.name,
            quantity: 1,
            unitPrice: product.promoPrice ?? product.basePrice,
          ),
        );
      }
    });
  }

  void _showCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Carrito (${_items.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        'S/ ${_subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(child: Text('Aún no agregó productos.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, index) => _SaleCartItem(
                            item: _items[index],
                            product: _product(_items[index].productId),
                            onDecrease: () {
                              setState(() {
                                final item = _items[index];
                                if (item.quantity <= 1) {
                                  _items.removeAt(index);
                                } else {
                                  _items[index] = SaleItem(
                                    productId: item.productId,
                                    productName: item.productName,
                                    quantity: item.quantity - 1,
                                    unitPrice: item.unitPrice,
                                    discount: item.discount,
                                  );
                                }
                              });
                              setSheetState(() {});
                            },
                            onIncrease: () {
                              final item = _items[index];
                              final stock = _product(item.productId)?.availableStock ?? 0;
                              if (item.quantity >= stock) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Solo hay $stock unidad(es) disponible(s).')),
                                );
                                return;
                              }
                              setState(() {
                                _items[index] = SaleItem(
                                  productId: item.productId,
                                  productName: item.productName,
                                  quantity: item.quantity + 1,
                                  unitPrice: item.unitPrice,
                                  discount: item.discount,
                                );
                              });
                              setSheetState(() {});
                            },
                            onRemove: () {
                              setState(() => _items.removeAt(index));
                              setSheetState(() {});
                            },
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _items.isEmpty
                          ? null
                          : () {
                              Navigator.of(sheetContext).pop();
                              setState(() => _showCheckout = true);
                            },
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Ir a cobrar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemTile(MapEntry<int, SaleItem> entry) {
    final item = entry.value;
    final product = _product(item.productId);
    final isDirectSale = widget.order == null;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 6),
      child: ListTile(
        title: Text(
          product?.name ?? 'Producto #${item.productId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: isDirectSale
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product == null
                        ? 'Disponible: 0 unidad(es)'
                        : 'Stock: ${product.totalStock} | Reservado: ${product.reservedStock} | Disponible: ${product.availableStock}',
                  ),
                  if (product != null) ...[
                    const SizedBox(height: 4),
                    _SalePriceVariationHint(
                      referencePrice: product.promoPrice ?? product.basePrice,
                      selectedPrice: item.unitPrice,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _SaleNumberInput(
                          label: 'Cantidad',
                          initial: item.quantity,
                          maximum: product?.availableStock.toDouble(),
                          wholeNumber: true,
                          onChanged: (quantity) => _replaceItem(
                            entry.key,
                            SaleItem(
                              productId: item.productId,
                              productName: item.productName,
                              quantity: quantity,
                              unitPrice: item.unitPrice,
                              discount: item.discount,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SaleNumberInput(
                          label: 'Precio',
                          initial: item.unitPrice,
                          onChanged: (price) => _replaceItem(
                            entry.key,
                            SaleItem(
                              productId: item.productId,
                              productName: item.productName,
                              quantity: item.quantity,
                              unitPrice: price,
                              discount: item.discount,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Subtotal: S/ ${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              )
            : Text(
          '${item.quantity.toInt()} × S/ ${item.unitPrice.toStringAsFixed(2)}',
        ),
        trailing: isDirectSale
            ? IconButton(
                tooltip: 'Quitar producto',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _items.removeAt(entry.key)),
              )
            : Text(
                'S/ ${item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  void _replaceItem(int index, SaleItem item) {
    setState(() => _items[index] = item);
  }

  Product? _product(int id) {
    return _productsById[id];
  }

  Future<void> _addProduct() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SaleBloc>(),
        child: BlocBuilder<SaleBloc, SaleState>(
          builder: (sheetContext, state) => SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * .78,
            child: ProductSelectorSheet(
              products: state.products,
              categories: state.productCategories,
              selectedCategoryIds: state.selectedProductCategoryIds,
              availableOnly: state.availableProductsOnly,
              searchQuery: state.productSearchQuery,
              hasMore: state.hasMoreProducts,
              isLoadingMore: state.isLoadingMoreProducts,
              onLoadMore: () => sheetContext.read<SaleBloc>().add(
                const LoadMoreSaleProducts(),
              ),
              onSearchChanged: (query) =>
                  sheetContext.read<SaleBloc>().add(SearchSaleProducts(query)),
              onFiltersChanged: (categoryIds, availableOnly) =>
                  sheetContext.read<SaleBloc>().add(
                    FilterSaleProducts(
                      categoryIds: categoryIds,
                      availableOnly: availableOnly,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
    if (product == null) return;
    if (product.availableStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El producto no tiene stock disponible.')),
      );
      return;
    }
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );
    if (existingIndex >= 0 &&
        _items[existingIndex].quantity >= product.availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo hay ${product.availableStock} unidad(es) disponible(s).',
          ),
        ),
      );
      return;
    }
    setState(() {
      _productsById[product.id] = product;
      if (existingIndex >= 0) {
        final old = _items[existingIndex];
        _items[existingIndex] = SaleItem(
          productId: old.productId,
          productName: old.productName,
          quantity: old.quantity + 1,
          unitPrice: old.unitPrice,
          discount: old.discount,
        );
      } else {
        _items.add(
          SaleItem(
            productId: product.id,
            quantity: 1,
            unitPrice: product.promoPrice ?? product.basePrice,
          ),
        );
      }
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false) || _items.isEmpty) return;
    if (widget.order == null) {
      for (final item in _items) {
        final product = _product(item.productId);
        if (item.quantity % 1 != 0 ||
            product == null ||
            item.quantity > product.availableStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'La cantidad de ${product?.name ?? 'este producto'} supera el stock disponible.',
              ),
            ),
          );
          return;
        }
      }
    }
    if ((_paid - _total).abs() >= .01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La suma de los pagos debe coincidir con el total.'),
        ),
      );
      return;
    }
    final sale = Sale(
      // El backend asigna el número según la fecha y hora del servidor.
      saleNumber: '',
      orderId: widget.order?.id,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      discount: _discountAmount,
      items: _items,
      payments: _payments
          .map(
            (payment) => SalePayment(
              paymentMethod: payment.method,
              amount: double.parse(payment.amount.text),
              receivedAmount: payment.method == 'CASH'
                  ? double.tryParse(payment.received.text)
                  : null,
              reference: payment.reference.text.trim().isEmpty
                  ? null
                  : payment.reference.text.trim(),
            ),
          )
          .toList(),
    );
    context.read<SaleBloc>().add(SaveSale(sale));
  }
}

class _SaleCartBar extends StatelessWidget {
  const _SaleCartBar({
    required this.itemCount,
    required this.total,
    required this.onOpenCart,
    required this.onCheckout,
  });

  final int itemCount;
  final double total;
  final VoidCallback onOpenCart;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Material(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenCart,
                icon: Badge(
                  isLabelVisible: itemCount > 0,
                  label: Text('$itemCount'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                label: Text(itemCount == 0 ? 'Carrito' : 'S/ ${total.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Cobrar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SaleCartItem extends StatelessWidget {
  const _SaleCartItem({
    required this.item,
    required this.product,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final SaleItem item;
  final Product? product;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? item.productName ?? 'Producto #${item.productId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'S/ ${item.unitPrice.toStringAsFixed(2)} c/u · S/ ${item.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Restar una unidad',
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            item.quantity.toInt().toString(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          IconButton(
            tooltip: 'Agregar una unidad',
            onPressed: onIncrease,
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'Quitar producto',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    ),
  );
}

class _SalePriceVariationHint extends StatelessWidget {
  const _SalePriceVariationHint({
    required this.referencePrice,
    required this.selectedPrice,
  });

  final double referencePrice;
  final double selectedPrice;

  @override
  Widget build(BuildContext context) {
    final difference = selectedPrice - referencePrice;
    final theme = Theme.of(context);
    if (difference.abs() < .005) {
      return Text(
        'Precio vigente: S/ ${referencePrice.toStringAsFixed(2)}',
        style: theme.textTheme.bodySmall,
      );
    }

    final isIncrease = difference > 0;
    final color = isIncrease ? Colors.orange.shade800 : Colors.green.shade700;
    final prefix = isIncrease ? '+' : '-';
    return Text(
      'Precio vigente: S/ ${referencePrice.toStringAsFixed(2)} / $prefix S/ ${difference.abs().toStringAsFixed(2)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SaleNumberInput extends StatelessWidget {
  const _SaleNumberInput({
    required this.label,
    required this.initial,
    required this.onChanged,
    this.maximum,
    this.wholeNumber = false,
  });

  final String label;
  final double initial;
  final double? maximum;
  final bool wholeNumber;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: wholeNumber
        ? initial.toInt().toString()
        : initial.toStringAsFixed(2),
    keyboardType: TextInputType.numberWithOptions(decimal: !wholeNumber),
    inputFormatters: wholeNumber
        ? [FilteringTextInputFormatter.digitsOnly]
        : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(labelText: label, isDense: true),
    validator: (value) {
      final number = double.tryParse(value ?? '');
      if (number == null || number <= 0) {
        return 'Ingrese un valor mayor que cero';
      }
      if (wholeNumber && number % 1 != 0) return 'Ingrese un nÃºmero entero';
      if (maximum != null && number > maximum!) {
        return 'MÃ¡ximo: ${maximum!.toInt()}';
      }
      return null;
    },
    onChanged: (value) {
      final number = double.tryParse(value);
      if (number != null &&
          number > 0 &&
          (!wholeNumber || number % 1 == 0)) {
        onChanged(number);
      }
    },
  );
}

class _PaymentDraft {
  String method = 'CASH';
  final amount = TextEditingController();
  final reference = TextEditingController();
  final received = TextEditingController();

  void dispose() {
    amount.dispose();
    reference.dispose();
    received.dispose();
  }
}

class _PaymentSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final double paid;
  const _PaymentSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    final complete = (paid - total).abs() < .01;
    final pending = total - paid;
    final color = complete
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
    final progress = total <= 0
        ? 0.0
        : (paid / total).clamp(0.0, 1.0).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: .72)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL A COBRAR',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'S/ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Subtotal S/ ${subtotal.toStringAsFixed(2)}${discount > 0 ? '  ·  Descuento -S/ ${discount.toStringAsFixed(2)}' : ''}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                complete ? Icons.verified_rounded : Icons.pending_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  complete
                      ? 'Pago completo'
                      : 'Falta S/ ${pending > 0 ? pending.toStringAsFixed(2) : '0.00'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Ingresado: S/ ${paid.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final _PaymentDraft draft;
  final bool removable;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _PaymentRow({
    required this.draft,
    required this.removable,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final selector = DropdownButtonFormField<String>(
        value: draft.method,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Método'),
        items: const [
          DropdownMenuItem(value: 'CASH', child: Text('Efectivo')),
          DropdownMenuItem(value: 'YAPE', child: Text('Yape')),
          DropdownMenuItem(value: 'PLIN', child: Text('Plin')),
          DropdownMenuItem(value: 'CARD', child: Text('Tarjeta')),
          DropdownMenuItem(value: 'TRANSFER', child: Text('Transferencia')),
        ],
        onChanged: (value) {
          draft.method = value!;
          onChanged();
        },
      );
      final amount = TextFormField(
        controller: draft.amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Monto aplicado',
          helperText: 'Parte de la venta cubierta con este método',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        validator: (value) =>
            (double.tryParse(value ?? '') ?? 0) <= 0 ? 'Monto inválido' : null,
        onChanged: (_) => onChanged(),
      );
      final received = draft.method == 'CASH'
          ? TextFormField(
              controller: draft.received,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Efectivo entregado',
                helperText: 'El vuelto se calcula automáticamente',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                final paid = double.tryParse(value ?? '') ?? 0;
                final applied = double.tryParse(draft.amount.text) ?? 0;
                return paid < applied ? 'Debe cubrir el monto aplicado' : null;
              },
              onChanged: (_) => onChanged(),
            )
          : null;
      final remove = removable
          ? IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onRemove,
            )
          : null;

      if (constraints.maxWidth < 380) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(top: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                selector,
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: amount),
                    if (remove != null) remove,
                  ],
                ),
                if (received != null) ...[
                  const SizedBox(height: 8),
                  received,
                  if ((double.tryParse(draft.received.text) ?? 0) >=
                      (double.tryParse(draft.amount.text) ?? 0))
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Vuelto: S/ ${((double.tryParse(draft.received.text) ?? 0) - (double.tryParse(draft.amount.text) ?? 0)).toStringAsFixed(2)}',
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      }

      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: selector),
              const SizedBox(width: 8),
              Expanded(child: amount),
              if (received != null) ...[
                const SizedBox(width: 8),
                Expanded(child: received),
              ],
              if (remove != null) remove,
            ],
          ),
        ),
      );
    },
  );
}
