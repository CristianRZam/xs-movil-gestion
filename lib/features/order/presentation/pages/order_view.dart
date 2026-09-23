import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'dart:async';

import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_bloc.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_event.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_state.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});
  @override State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  String _query = '';
  String _status = 'ALL';

  @override
  Widget build(BuildContext context) => BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == OrderStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<OrderBloc>().add(const ClearOrderError());
          }
          if (state.savedOrder != null || state.deleted == true) {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) navigator.pop(true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operación realizada correctamente')));
            context.read<OrderBloc>().add(const ClearOrderAction());
          }
        },
        builder: (context, state) {
          final orders = state.orders.where((order) {
            final matchesQuery = order.orderNumber.toLowerCase().contains(_query.toLowerCase()) ||
                (order.tableNumber ?? '').toLowerCase().contains(_query.toLowerCase());
            return matchesQuery && (_status == 'ALL' || order.status == _status);
          }).toList();
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const XsAppBar(title: 'Órdenes y ventas', backIcon: false),
            endDrawer: const XsDrawer(),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: state.isCashSessionOpen == true
                  ? () => _openOrderForm(context)
                  : null,
              icon: const Icon(Icons.add), label: const Text('Nueva orden'),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<OrderBloc>().add(const LoadOrders());
                  context.read<OrderBloc>().add(const LoadOrderProducts());
                  context.read<OrderBloc>().add(const CheckOpenCashSession());
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
                  children: [
                    if (state.isCashSessionOpen != true) ...[
                      _CashSessionRequiredCard(
                        isChecking: state.isCashSessionOpen == null,
                        onOpenCashSession: () => Navigator.pushNamed(
                          context,
                          AppRoutes.cashSession,
                        ).then(
                          (_) => context
                              .read<OrderBloc>()
                              .add(const CheckOpenCashSession()),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        labelText: 'Buscar por número o mesa', prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('Todos los estados')),
                        DropdownMenuItem(value: 'PENDING', child: Text('Pendiente')),
                        DropdownMenuItem(value: 'PREPARING', child: Text('En preparación')),
                        DropdownMenuItem(value: 'READY', child: Text('Lista')),
                        DropdownMenuItem(value: 'COMPLETED', child: Text('Completada')),
                        DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelada')),
                      ],
                      onChanged: (value) => setState(() => _status = value ?? 'ALL'),
                    ),
                    const SizedBox(height: 18),
                    if (orders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Center(child: Text('No se encontraron órdenes.')),
                      )
                    else
                      ...orders.map((order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderCard(
                          order: order,
                          onTap: () => _showOrderDetail(context, order, state.products),
                        ),
                      )),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _CashSessionRequiredCard extends StatelessWidget {
  final bool isChecking;
  final VoidCallback onOpenCashSession;

  const _CashSessionRequiredCard({
    required this.isChecking,
    required this.onOpenCashSession,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: AppColors.primary.withValues(alpha: .10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.point_of_sale_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChecking
                          ? 'Verificando sesión de caja...'
                          : 'Necesitas abrir una caja para crear órdenes.',
                    ),
                    if (!isChecking) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onOpenCashSession,
                        icon: const Icon(Icons.lock_open_rounded),
                        label: const Text('Ir a Caja'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: .25))),
      child: InkWell(
        borderRadius: BorderRadius.circular(16), onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
              _StatusChip(status: order.status ?? 'PENDING'),
            ]),
            const SizedBox(height: 8),
            Text('${_typeLabel(order.orderType)}${order.tableNumber?.isNotEmpty == true ? ' · ${order.tableNumber}' : ''}'),
            const SizedBox(height: 12),
            Row(children: [
              Text('${order.items.length} producto(s)', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(), Text('S/ ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Text(_statusLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)));
  }
}

void _showOrderDetail(BuildContext context, Order order, List<Product> products) {
  showModalBottomSheet(
    context: context, isScrollControlled: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false, initialChildSize: .76, maxChildSize: .93,
      builder: (_, controller) => ListView(controller: controller, padding: const EdgeInsets.all(20), children: [
        Row(children: [Expanded(child: Text(order.orderNumber, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), _StatusChip(status: order.status ?? 'PENDING')]),
        const SizedBox(height: 4), Text(_typeLabel(order.orderType)),
        if (order.notes?.isNotEmpty == true) ...[const SizedBox(height: 8), Text(order.notes!)],
        const Divider(height: 32),
        ...order.items.map((item) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_productName(products, item.productId)),
          subtitle: Text('${_quantity(item.quantity)} × S/ ${item.unitPrice.toStringAsFixed(2)}'),
          trailing: Text('S/ ${item.subtotal.toStringAsFixed(2)}'),
        )),
        const Divider(), Align(alignment: Alignment.centerRight, child: Text('Total: S/ ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        if (order.status == 'PENDING') ...[
          FilledButton.icon(onPressed: () async {
            final wasSaved = await _openOrderForm(
              context,
              order: order,
            );
            final sheetNavigator = Navigator.of(sheetContext);
            if (wasSaved == true && sheetNavigator.mounted) {
              sheetNavigator.pop();
            }
          }, icon: const Icon(Icons.edit), label: const Text('Editar orden')),
          const SizedBox(height: 10),
          if (getIt<AccessControl>().allows(AppCapability.deleteOrders))
          OutlinedButton.icon(onPressed: () => _confirmDelete(context, order), icon: const Icon(Icons.delete_outline), label: const Text('Eliminar orden')),
        ],
        if (_nextStatus(order.status) != null) ...[
          const SizedBox(height: 10),
          FilledButton.icon(onPressed: () => context.read<OrderBloc>().add(ChangeOrderStatus(order.id!, _nextStatus(order.status)!)), icon: const Icon(Icons.arrow_forward), label: Text('Marcar como ${_statusLabel(_nextStatus(order.status)!)}')),
        ],
        if (order.status != 'COMPLETED' && order.status != 'CANCELLED') ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.pushNamed(AppRoutes.sales, arguments: order).then((_) {
                if (navigator.mounted) {
                  context.read<OrderBloc>().add(const LoadOrders());
                  context.read<OrderBloc>().add(const LoadOrderProducts());
                }
              });
            },
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Cobrar orden'),
          ),
        ],
        if (order.status != 'COMPLETED' && order.status != 'CANCELLED') ...[
          const SizedBox(height: 10),
          TextButton(onPressed: () => _confirmCancel(context, order), child: const Text('Cancelar orden')),
        ],
      ]),
    ),
  );
}

void _confirmDelete(BuildContext context, Order order) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: const Text('Eliminar orden'), content: Text('¿Eliminar ${order.orderNumber}? Esta acción solo es válida para órdenes pendientes.'),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')), FilledButton(onPressed: () { Navigator.pop(dialogContext); context.read<OrderBloc>().add(DeleteOrder(order.id!)); }, child: const Text('Eliminar'))],
  ),
);

void _confirmCancel(BuildContext context, Order order) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
    title: const Text('¿Cancelar orden?'),
    content: Text('Se liberará el stock reservado de ${order.orderNumber}. Esta acción no se puede deshacer.'),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Volver')), FilledButton(onPressed: () { Navigator.pop(dialogContext); context.read<OrderBloc>().add(ChangeOrderStatus(order.id!, 'CANCELLED')); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Sí, cancelar'))],
  ),
);

Future<bool?> _openOrderForm(BuildContext context, {
  Order? order,
}) async {
  final bloc = context.read<OrderBloc>();
  final navigator = Navigator.of(context, rootNavigator: true);
  final completer = Completer<List<Product>>();
  bloc.add(RefreshOrderProducts(completer));

  try {
    // No reutilizar la lista recibida: puede haber sido reservada por otro
    // usuario mientras esta pantalla permanecía abierta.
    final freshProducts = await completer.future;
    if (!navigator.mounted) return null;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _OrderFormDialog(order: order, products: freshProducts),
      ),
    );
  } catch (_) {
    if (navigator.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la disponibilidad de productos.')),
      );
    }
    return null;
  }
}

class _OrderFormDialog extends StatefulWidget {
  final Order? order; final List<Product> products;
  const _OrderFormDialog({this.order, required this.products});
  @override State<_OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<_OrderFormDialog> {
  late final TextEditingController numberController;
  late final TextEditingController tableController;
  late final TextEditingController notesController;
  late String type;
  late List<OrderItem> items;
  late List<Product> availableProducts;
  final key = GlobalKey<FormState>();
  @override void initState() { super.initState(); final o = widget.order; numberController = TextEditingController(text: o?.orderNumber ?? ''); tableController = TextEditingController(text: o?.tableNumber); notesController = TextEditingController(text: o?.notes); type = o?.orderType ?? 'DINE_IN'; items = [...?o?.items]; availableProducts = [...widget.products]; }
  @override void dispose() { numberController.dispose(); tableController.dispose(); notesController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.order == null ? 'Nueva orden' : 'Editar orden'),
    content: SizedBox(width: 480, child: Form(key: key, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (widget.order == null)
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('El número de orden se generará al guardar.'),
        )
      else
        TextFormField(
          controller: numberController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Número de orden'),
        ),
      const SizedBox(height: 12), DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Tipo'), items: const [DropdownMenuItem(value: 'DINE_IN', child: Text('En local')), DropdownMenuItem(value: 'TAKEAWAY', child: Text('Para llevar')), DropdownMenuItem(value: 'DELIVERY', child: Text('Entrega'))], onChanged: (v) => setState(() => type = v!)),
      const SizedBox(height: 12), TextFormField(controller: tableController, decoration: const InputDecoration(labelText: 'Mesa o referencia')),
      const SizedBox(height: 12), TextFormField(controller: notesController, maxLines: 2, decoration: const InputDecoration(labelText: 'Notas')),
      const Divider(height: 30),
      Row(children: [const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), TextButton.icon(onPressed: availableProducts.isEmpty ? null : _addProduct, icon: const Icon(Icons.add), label: const Text('Agregar'))]),
      if (items.isEmpty) const Padding(padding: EdgeInsets.all(10), child: Text('Agregue al menos un producto.')),
      ...items.asMap().entries.map((entry) => _EditableItem(item: entry.value, productName: _productName(availableProducts, entry.value.productId), availableQuantity: _maximumQuantityForProduct(entry.value.productId), onChanged: (item) => setState(() => items[entry.key] = item), onDelete: () => setState(() => items.removeAt(entry.key)))),
      const SizedBox(height: 10), Align(alignment: Alignment.centerRight, child: Text('Total: S/ ${items.fold<double>(0, (sum, item) => sum + item.subtotal).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
    ])))),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: _submit, child: const Text('Guardar'))],
  );
  Future<void> _addProduct() async {
    final selected = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<OrderBloc>(),
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (sheetContext, state) => SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * .78,
            child: ProductSelectorSheet(
              products: state.products,
              hasMore: state.hasMoreProducts,
              isLoadingMore: state.isLoadingMoreProducts,
              onLoadMore: () => sheetContext
                  .read<OrderBloc>()
                  .add(const LoadMoreOrderProducts()),
              onSearchChanged: (query) => sheetContext
                  .read<OrderBloc>()
                  .add(SearchOrderProducts(query)),
            ),
          ),
        ),
      ),
    );
    if (selected == null) return;
    if (selected.availableStock == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El producto no tiene stock disponible.')));
      return;
    }
    final index = items.indexWhere((item) => item.productId == selected.id);
    final maximumQuantity = _maximumQuantityForProduct(selected.id);
    if (index >= 0 && items[index].quantity + 1 > maximumQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solo hay $maximumQuantity unidad(es) disponible(s).')));
      return;
    }
    setState(() { if (!availableProducts.any((product) => product.id == selected.id)) { availableProducts.add(selected); } if (index >= 0) { final old = items[index]; items[index] = OrderItem(id: old.id, productId: old.productId, quantity: old.quantity + 1, unitPrice: old.unitPrice, notes: old.notes); } else { items.add(OrderItem(productId: selected.id, quantity: 1, unitPrice: selected.promoPrice ?? selected.basePrice)); } });
  }
  void _submit() {
    if (!(key.currentState?.validate() ?? false)) return;
    if (items.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La orden debe incluir al menos un producto.'))); return; }
    for (final item in items) {
      final availableStock = _maximumQuantityForProduct(item.productId);
      if (availableStock < 0 || item.quantity > availableStock) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La cantidad de ${_productName(availableProducts, item.productId)} supera el stock disponible.')));
        return;
      }
    }
    context.read<OrderBloc>().add(SaveOrder(Order(id: widget.order?.id, orderNumber: numberController.text.trim(), orderType: type, tableNumber: _nullIfBlank(tableController.text), notes: _nullIfBlank(notesController.text), items: items, status: widget.order?.status)));
  }

  int _maximumQuantityForProduct(int productId) {
    final availableStock = _availableStock(availableProducts, productId);
    if (availableStock < 0 || widget.order == null) return availableStock;

    final originallyReserved = widget.order!.items
        .where((item) => item.productId == productId)
        .fold<double>(0, (sum, item) => sum + item.quantity);

    return availableStock + originallyReserved.toInt();
  }
}

class _EditableItem extends StatelessWidget {
  final OrderItem item;
  final String productName;
  final int availableQuantity;
  final ValueChanged<OrderItem> onChanged;
  final VoidCallback onDelete;

  const _EditableItem({required this.item, required this.productName, required this.availableQuantity, required this.onChanged, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(productName)), IconButton(onPressed: onDelete, icon: const Icon(Icons.close))]),
    Text('Disponible: $availableQuantity', style: Theme.of(context).textTheme.bodySmall),
    Row(children: [Expanded(child: _NumberInput(label: 'Cantidad', initial: item.quantity, maximum: availableQuantity.toDouble(), wholeNumber: true, onChanged: (v) => onChanged(OrderItem(id: item.id, productId: item.productId, quantity: v, unitPrice: item.unitPrice, notes: item.notes)))), const SizedBox(width: 8), Expanded(child: _NumberInput(label: 'Precio', initial: item.unitPrice, onChanged: (v) => onChanged(OrderItem(id: item.id, productId: item.productId, quantity: item.quantity, unitPrice: v, notes: item.notes))))]),
    TextFormField(initialValue: item.notes, maxLines: 2, maxLength: 255, decoration: const InputDecoration(labelText: 'Notas del producto', hintText: 'Ej.: con leche, dos azúcares'), onChanged: (value) => onChanged(OrderItem(id: item.id, productId: item.productId, quantity: item.quantity, unitPrice: item.unitPrice, notes: _nullIfBlank(value)))),
    Align(alignment: Alignment.centerRight, child: Text('Subtotal: S/ ${item.subtotal.toStringAsFixed(2)}')),
  ])));
}

class _NumberInput extends StatelessWidget {
  final String label;
  final double initial;
  final double? maximum;
  final bool wholeNumber;
  final ValueChanged<double> onChanged;
  const _NumberInput({required this.label, required this.initial, this.maximum, this.wholeNumber = false, required this.onChanged});
  @override Widget build(BuildContext context) => TextFormField(initialValue: initial.toString(), keyboardType: TextInputType.numberWithOptions(decimal: !wholeNumber), autovalidateMode: AutovalidateMode.onUserInteraction, decoration: InputDecoration(labelText: label, isDense: true), validator: (value) { final number = double.tryParse(value ?? ''); if (number == null || number <= 0) return 'Ingrese un valor mayor que cero'; if (wholeNumber && number % 1 != 0) return 'Ingrese un número entero'; if (maximum != null && number > maximum!) return 'Máximo: ${maximum!.toInt()}'; return null; }, onChanged: (v) { final number = double.tryParse(v); if (number != null && number > 0) onChanged(number); });
}

String _productName(List<Product> products, int id) {
  for (final product in products) {
    if (product.id == id) return product.name;
  }
  return 'Producto #$id';
}
int _availableStock(List<Product> products, int id) {
  for (final product in products) {
    if (product.id == id) return product.availableStock;
  }
  return -1;
}
String? _nullIfBlank(String value) => value.trim().isEmpty ? null : value.trim();
String _quantity(double value) => value % 1 == 0 ? value.toInt().toString() : value.toString();
String _typeLabel(String type) => switch (type) {'DINE_IN' => 'En local', 'TAKEAWAY' => 'Para llevar', 'DELIVERY' => 'Entrega', _ => type};
String _statusLabel(String status) => switch (status) {'PENDING' => 'PENDIENTE', 'PREPARING' => 'EN PREPARACIÓN', 'READY' => 'LISTA', 'COMPLETED' => 'COMPLETADA', 'CANCELLED' => 'CANCELADA', _ => status};
Color _statusColor(String? status) => switch (status) {'PENDING' => Colors.orange, 'PREPARING' => Colors.blue, 'READY' => Colors.green, 'COMPLETED' => Colors.teal, 'CANCELLED' => Colors.red, _ => AppColors.primary};
String? _nextStatus(String? status) => switch (status) {'PENDING' => 'PREPARING', 'PREPARING' => 'READY', _ => null};
