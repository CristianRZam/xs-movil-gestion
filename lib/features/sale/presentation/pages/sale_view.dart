import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleView extends StatelessWidget {
  final Order? order;

  const SaleView({super.key, this.order});

  @override
  Widget build(BuildContext context) => BlocConsumer<SaleBloc, SaleState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
            context.read<SaleBloc>().add(const ClearSaleMessage());
          }
          if (state.saved) {
            Navigator.of(context, rootNavigator: true).maybePop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Venta registrada correctamente')),
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
                    child: Text('Abra una sesión de caja antes de registrar ventas.'),
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
              ...state.sales.map(
                (sale) => Card(
                  child: ListTile(
                    title: Text(sale.saleNumber),
                    subtitle: Text(
                      '${sale.payments.map((p) => p.paymentMethod).join(' + ')} · '
                      '${sale.items.length} producto(s)',
                    ),
                    trailing: Text('S/ ${sale.total.toStringAsFixed(2)}'),
                    onTap: () => _showSaleDetail(context, sale, state.products),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    builder: (_) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .65,
        maxChildSize: .9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text(sale.saleNumber, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Estado: ${sale.status ?? 'COMPLETED'}'),
            const SizedBox(height: 4),
            Text('Registrada por: ${sale.createdByName ?? 'Usuario no disponible'}'),
            const Divider(height: 28),
            const Text('Productos consumidos', style: TextStyle(fontWeight: FontWeight.bold)),
            ...sale.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(productName(item.productId)),
                subtitle: Text('${item.quantity.toInt()} × S/ ${item.unitPrice.toStringAsFixed(2)}'),
                trailing: Text('S/ ${item.subtotal.toStringAsFixed(2)}'),
              ),
            ),
            const Divider(height: 28),
            const Text('Formas de pago', style: TextStyle(fontWeight: FontWeight.bold)),
            ...sale.payments.map(
              (payment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined),
                title: Text(_paymentLabel(payment.paymentMethod)),
                subtitle: payment.reference == null ? null : Text('Referencia: ${payment.reference}'),
                trailing: Text('S/ ${payment.amount.toStringAsFixed(2)}'),
              ),
            ),
            const Divider(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: S/ ${sale.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
}

String _paymentLabel(String method) => switch (method) {
      'CASH' => 'Efectivo',
      'YAPE' => 'Yape',
      'CARD' => 'Tarjeta',
      'TRANSFER' => 'Transferencia',
      _ => method,
    };

void _openSaleForm(BuildContext context, List<Product> products, {Order? order}) {
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

  @override
  void initState() {
    super.initState();
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

  double get _total => _items.fold<double>(0, (sum, item) => sum + item.subtotal);
  double get _paid => _payments.fold<double>(
        0,
        (sum, payment) => sum + (double.tryParse(payment.amount.text) ?? 0),
      );

  @override
  void dispose() {
    for (final payment in _payments) {
      payment.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          widget.order == null
              ? 'Nueva venta directa'
              : 'Cobrar',
        ),
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
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _PaymentSummary(total: _total, paid: _paid),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined),
                      const SizedBox(width: 8),
                      const Text('Productos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                  const Row(children: [Icon(Icons.account_balance_wallet_outlined), SizedBox(width: 8), Text('Formas de pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
                  const SizedBox(height: 4),
                  Text('Puedes combinar varios medios para completar el cobro.', style: Theme.of(context).textTheme.bodySmall),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.lock_open_rounded), label: const Text('Confirmar cobro')),
        ],
      );

  Widget _itemTile(MapEntry<int, SaleItem> entry) {
    final item = entry.value;
    final product = _product(item.productId);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 6),
      child: ListTile(
      title: Text(product?.name ?? 'Producto #${item.productId}', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${item.quantity.toInt()} × S/ ${item.unitPrice.toStringAsFixed(2)}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('S/ ${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)), if (widget.order == null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _items.removeAt(entry.key)),
          )]),
    ));
  }

  Product? _product(int id) {
    for (final product in widget.products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> _addProduct() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      builder: (_) => ListView(
        children: widget.products
            .where((product) => product.availableStock > 0)
            .map(
              (product) => ListTile(
                title: Text(product.name),
                subtitle: Text('Disponible: ${product.availableStock}'),
                onTap: () => Navigator.pop(context, product),
              ),
            )
            .toList(),
      ),
    );
    if (product == null) return;
    setState(() {
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
        const SnackBar(content: Text('La suma de los pagos debe coincidir con el total.')),
      );
      return;
    }
    final sale = Sale(
      // El backend asigna el número según la fecha y hora del servidor.
      saleNumber: '',
      orderId: widget.order?.id,
      items: _items,
      payments: _payments
          .map(
            (payment) => SalePayment(
              paymentMethod: payment.method,
              amount: double.parse(payment.amount.text),
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

  void dispose() {
    amount.dispose();
    reference.dispose();
  }
}

class _PaymentSummary extends StatelessWidget {
  final double total;
  final double paid;
  const _PaymentSummary({required this.total, required this.paid});

  @override
  Widget build(BuildContext context) {
    final complete = (paid - total).abs() < .01;
    final pending = total - paid;
    final color = complete ? Colors.green : Theme.of(context).colorScheme.primary;
    final progress = total <= 0 ? 0.0 : (paid / total).clamp(0.0, 1.0).toDouble();
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
          Text('TOTAL A COBRAR', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 3),
          Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 7, color: Colors.white, backgroundColor: Colors.white24)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(complete ? Icons.verified_rounded : Icons.pending_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(complete ? 'Pago completo' : 'Falta S/ ${pending > 0 ? pending.toStringAsFixed(2) : '0.00'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            Text('Ingresado: S/ ${paid.toStringAsFixed(2)}', style: TextStyle(color: Colors.white.withValues(alpha: .9), fontSize: 11)),
          ]),
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
            decoration: const InputDecoration(labelText: 'Monto'),
            validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                ? 'Monto inválido'
                : null,
            onChanged: (_) => onChanged(),
          );
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
                  Row(children: [Expanded(child: amount), if (remove != null) remove]),
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
                if (remove != null) remove,
              ],
              ),
            ),
          );
        },
      );
}
