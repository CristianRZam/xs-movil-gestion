import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleView extends StatelessWidget {
  final Order? order;

  const SaleView({super.key, this.order});

  @override
  Widget build(BuildContext context) => BlocConsumer<SaleBloc, SaleState>(
    listenWhen: (previous, current) =>
        (previous.error != current.error && current.error != null) ||
        (!previous.saved && current.saved) ||
        (!previous.cancelled && current.cancelled),
    listener: (context, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!)));
        context.read<SaleBloc>().add(const ClearSaleMessage());
      }
      if (state.saved) {
        Navigator.of(context, rootNavigator: true).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada correctamente')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.cashOpen == true
            ? () => _openSaleForm(context, state.products, order: order)
            : null,
        icon: const Icon(Icons.point_of_sale),
        label: Text(order == null ? 'Nueva venta' : 'Cobrar orden'),
      ),
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
                subtitle: const Text(
                  'Los productos y cantidades quedan bloqueados al cobrar una orden.',
                ),
              ),
            ),
          const SizedBox(height: 10),
          _SaleDateFilters(state: state),
          const SizedBox(height: 12),
          if (state.sales.isEmpty && state.status != SaleStatus.loading)
            const Padding(
              padding: EdgeInsets.only(top: 32, bottom: 20),
              child: Center(
                child: Text('No se encontraron ventas en este período.'),
              ),
            ),
          ...state.sales.map(
            (sale) => Card(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(sale.saleNumber)),
                    const SizedBox(width: 8),
                    _SaleStatusBadge(status: sale.status),
                  ],
                ),
                subtitle: Text(
                  '${sale.payments.map((p) => p.paymentMethod).join(' + ')} · '
                  '${sale.items.length} producto(s)',
                ),
                trailing: Text('S/ ${sale.total.toStringAsFixed(2)}'),
                onTap: () => _showSaleDetail(context, sale, state.products),
              ),
            ),
          ),
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

class _SaleDateFilters extends StatelessWidget {
  const _SaleDateFilters({required this.state});
  final SaleState state;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _chip(context, 'Todos', SaleDateFilter.all),
        _chip(context, 'Hoy', SaleDateFilter.today),
        _chip(context, 'Esta semana', SaleDateFilter.week),
        _chip(context, 'Este mes', SaleDateFilter.month),
        _chip(context, 'Personalizado', SaleDateFilter.custom),
      ],
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
            Text('Estado: ${sale.status ?? 'COMPLETED'}'),
            const SizedBox(height: 4),
            Text(
              'Registrada por: ${sale.createdByName ?? 'Usuario no disponible'}',
            ),
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
  'CARD' => 'Tarjeta',
  'TRANSFER' => 'Transferencia',
  _ => method,
};

void _openSaleForm(
  BuildContext context,
  List<Product> products, {
  Order? order,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<SaleBloc>(),
      child: _SaleForm(products: products, order: order),
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

  @override
  void initState() {
    super.initState();
    _productsById.addEntries(
      widget.products.map((product) => MapEntry(product.id, product)),
    );
    _payments.add(_PaymentDraft());
    final order = widget.order;
    if (order != null) {
      _items.addAll(
        order.items.map(
          (item) => SaleItem(
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ),
        ),
      );
    }
  }

  double get _subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.subtotal);
  double get _discountAmount => double.tryParse(_discount.text) ?? 0;
  double get _total => (_subtotal - _discountAmount).clamp(0, double.infinity);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    title: Text(widget.order == null ? 'Nueva venta directa' : 'Cobrar'),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                  labelText: 'Descuento (S/)',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                validator: (value) => _discountAmount > _subtotal
                    ? 'El descuento no puede superar el subtotal'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _PaymentSummary(
                subtotal: _subtotal,
                discount: _discountAmount,
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
                  if (widget.order == null)
                    TextButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                    ),
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
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.lock_open_rounded),
        label: const Text('Confirmar cobro'),
      ),
    ],
  );

  Widget _itemTile(MapEntry<int, SaleItem> entry) {
    final item = entry.value;
    final product = _product(item.productId);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 6),
      child: ListTile(
        title: Text(
          product?.name ?? 'Producto #${item.productId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.quantity.toInt()} × S/ ${item.unitPrice.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'S/ ${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (widget.order == null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _items.removeAt(entry.key)),
              ),
          ],
        ),
      ),
    );
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
              hasMore: state.hasMoreProducts,
              isLoadingMore: state.isLoadingMoreProducts,
              onLoadMore: () => sheetContext.read<SaleBloc>().add(
                const LoadMoreSaleProducts(),
              ),
              onSearchChanged: (query) =>
                  sheetContext.read<SaleBloc>().add(SearchSaleProducts(query)),
            ),
          ),
        ),
      ),
    );
    if (product == null) return;
    setState(() {
      _productsById[product.id] = product;
      final index = _items.indexWhere((item) => item.productId == product.id);
      if (index >= 0) {
        final old = _items[index];
        if (old.quantity < product.availableStock) {
          _items[index] = SaleItem(
            productId: old.productId,
            quantity: old.quantity + 1,
            unitPrice: old.unitPrice,
          );
        }
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
