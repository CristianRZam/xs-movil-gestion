import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
            title: order == null ? 'Ventas' : 'Cobrar ${order!.orderNumber}',
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
        title: Text(
          widget.order == null
              ? 'Nueva venta directa'
              : 'Cobrar ${widget.order!.orderNumber}',
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
                  Row(
                    children: [
                      const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const Divider(),
                  const Text('Pagos', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  TextButton.icon(
                    onPressed: () => setState(() => _payments.add(_PaymentDraft())),
                    icon: const Icon(Icons.add_card),
                    label: const Text('Agregar método de pago'),
                  ),
                  const Divider(),
                  Text(
                    'Total: S/ ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Pagado: S/ ${_paid.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: (_paid - _total).abs() < .01 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: _save, child: const Text('Cobrar')),
        ],
      );

  Widget _itemTile(MapEntry<int, SaleItem> entry) {
    final item = entry.value;
    final product = _product(item.productId);
    return ListTile(
      title: Text(product?.name ?? 'Producto #${item.productId}'),
      subtitle: Text('${item.quantity.toInt()} × S/ ${item.unitPrice.toStringAsFixed(2)}'),
      trailing: widget.order == null
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _items.removeAt(entry.key)),
            )
          : null,
    );
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
      saleNumber: 'V-${DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now())}',
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
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: draft.method,
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
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: draft.amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto'),
              validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                  ? 'Monto inválido'
                  : null,
              onChanged: (_) => onChanged(),
            ),
          ),
          if (removable)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onRemove,
            ),
        ],
      );
}
