import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'dart:async';

import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_bloc.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_event.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_state.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});
  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderItemTrailingAction extends StatelessWidget {
  const _OrderItemTrailingAction({required this.order, required this.item});

  final Order order;
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final isActiveOrder = order.status != 'COMPLETED' && order.status != 'CANCELLED';
    final nextStatus = _nextItemStatus(item.status);
    final capability = !isActiveOrder || nextStatus == null
        ? null
        : _capabilityForItemStatus(nextStatus);
    final canUpdate = nextStatus != null &&
        capability != null &&
        item.id != null &&
        order.id != null &&
        getIt<AccessControl>().allows(capability);
    final canReportIncident = isActiveOrder && item.status == 'SERVED' && item.id != null && order.id != null &&
        getIt<AccessControl>().allows(AppCapability.reportOrderIncident) &&
        getIt<AccessControl>().allows(AppCapability.approveOrderCompensation);
    final canCancel = isActiveOrder && item.status != 'CANCELLED' && item.id != null && order.id != null &&
        getIt<AccessControl>().allows(AppCapability.cancelOrderItem);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canUpdate)
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            icon: const Icon(Icons.play_circle_outline, size: 17),
            label: Text(
              _itemStatusActionLabel(nextStatus!),
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: () => context.read<OrderBloc>().add(
              ChangeOrderItemStatus(order.id!, item.id!, nextStatus!),
            ),
          ),
        if (canReportIncident)
          IconButton(
            tooltip: 'Registrar incidencia',
            visualDensity: VisualDensity.compact,
            color: Colors.red.shade700,
            icon: const Icon(Icons.add_alert_outlined, size: 20),
            onPressed: () => _showIncidentDialog(context, order.id!, item.id!),
          ),
        if (canCancel)
          IconButton(
            tooltip: 'Cancelar producto',
            visualDensity: VisualDensity.compact,
            color: Colors.red.shade700,
            icon: const Icon(Icons.cancel_outlined, size: 19),
            onPressed: () => _showCancelOrderItemDialog(context, order.id!, item.id!),
          ),
      ],
    );
  }
}

class _OrderItemStatusBadge extends StatelessWidget {
  const _OrderItemStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _itemStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _itemStatusLabel(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DashedItemDivider extends StatelessWidget {
  const _DashedItemDivider();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final dashCount = (constraints.maxWidth / 8).floor();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Wrap(
          spacing: 4,
          children: List.generate(
            dashCount,
            (_) => Container(
              width: 4,
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .45),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showIncidentDialog(BuildContext context, int orderId, int itemId) async {
  final reason = TextEditingController();
  final discount = TextEditingController();
  var resolution = 'CANCEL_NO_CHARGE';
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setDialogState) => AlertDialog(
        title: const Text('Registrar incidencia'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(value: resolution, items: const [
            DropdownMenuItem(value: 'CANCEL_NO_CHARGE', child: Text('No cobrar producto')),
            DropdownMenuItem(value: 'REPLACE', child: Text('Reponer producto')),
            DropdownMenuItem(value: 'DISCOUNT', child: Text('Aplicar descuento')),
          ], onChanged: (value) => setDialogState(() => resolution = value ?? resolution)),
          const SizedBox(height: 12),
          TextField(controller: reason, maxLength: 500, maxLines: 3, decoration: const InputDecoration(labelText: 'Motivo')),
          if (resolution == 'DISCOUNT') TextField(controller: discount, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))], decoration: const InputDecoration(labelText: 'Descuento (S/)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            final incidentReason = reason.text.trim();
            final amount = double.tryParse(discount.text);
            if (incidentReason.isEmpty || (resolution == 'DISCOUNT' && (amount == null || amount <= 0))) return;
            Navigator.pop(dialogContext);
            context.read<OrderBloc>().add(ReportOrderItemIncident(orderId, itemId, resolution, incidentReason, discountAmount: amount));
          }, child: const Text('Registrar')),
        ],
      ),
    ),
  );
  // El cierre de un diálogo es animado; liberar los controladores en el mismo
  // frame puede hacer que TextField los consulte durante su desmontaje.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  reason.dispose();
  discount.dispose();
}

Future<void> _showCancelOrderItemDialog(
  BuildContext context,
  int orderId,
  int itemId,
) async {
  final reason = TextEditingController();
  var stockDisposition = 'RETURN_TO_STOCK';
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setDialogState) => AlertDialog(
        title: const Text('Cancelar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reason,
              maxLength: 500,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Motivo de cancelación'),
            ),
            DropdownButtonFormField<String>(
              value: stockDisposition,
              decoration: const InputDecoration(labelText: 'Destino del producto'),
              items: const [
                DropdownMenuItem(
                  value: 'RETURN_TO_STOCK',
                  child: Text('Devuelto en buen estado'),
                ),
                DropdownMenuItem(
                  value: 'WASTE',
                  child: Text('No recuperable / merma'),
                ),
              ],
              onChanged: (value) => setDialogState(
                () => stockDisposition = value ?? stockDisposition,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () {
              final comment = reason.text.trim();
              if (comment.isEmpty) return;
              Navigator.pop(dialogContext);
              context.read<OrderBloc>().add(CancelPendingOrderItem(
                    orderId,
                    itemId,
                    comment: comment,
                    stockDisposition: stockDisposition,
                  ));
            },
            child: const Text('Cancelar producto'),
          ),
        ],
      ),
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  reason.dispose();
}

Future<void> _showAddOrderItem(
  BuildContext context,
  Order order,
  List<Product> products,
) async {
  final orderBloc = context.read<OrderBloc>();
  final selected = await showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
       value: orderBloc,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .78,
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (sheetContext, state) => ProductSelectorSheet(
            products: state.products.isEmpty ? products : state.products,
            hasMore: state.hasMoreProducts,
            isLoadingMore: state.isLoadingMoreProducts,
            onLoadMore: () => sheetContext.read<OrderBloc>().add(const LoadMoreOrderProducts()),
            onSearchChanged: (query) => sheetContext.read<OrderBloc>().add(SearchOrderProducts(query)),
          ),
        ),
      ),
    ),
  );
  if (selected == null || selected.id == null || selected.availableStock <= 0) return;
  if (!context.mounted) return;

  final quantityController = TextEditingController(text: '1');
  final priceController = TextEditingController(
    text: (selected.promoPrice ?? selected.basePrice).toStringAsFixed(2),
  );
  final notesController = TextEditingController();
  String fulfillmentType = order.orderType == 'TAKEAWAY' ? 'TAKEAWAY' : 'DINE_IN';
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: orderBloc,
      child: StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: Text('Agregar ${selected.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Text('Disponible: ${selected.availableStock}'),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              decoration: const InputDecoration(labelText: 'Precio unitario'),
            ),
            DropdownButtonFormField<String>(
              value: fulfillmentType,
              decoration: const InputDecoration(labelText: 'Entrega'),
              items: const [
                DropdownMenuItem(value: 'DINE_IN', child: Text('En local')),
                DropdownMenuItem(value: 'TAKEAWAY', child: Text('Para llevar')),
              ],
              onChanged: (value) => setDialogState(() => fulfillmentType = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLength: 255,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'Ej.: sin sal, sin hielo, bien cocido',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              final price = double.tryParse(priceController.text);
              if (quantity == null || quantity <= 0 || quantity > selected.availableStock || price == null || price < 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revise cantidad, disponibilidad y precio.')));
                return;
              }
              final notes = _nullIfBlank(notesController.text);
              Navigator.pop(dialogContext);
              orderBloc.add(AddOrderItem(
                order.id!,
                OrderItem(productId: selected.id!, quantity: quantity.toDouble(), unitPrice: price, fulfillmentType: fulfillmentType, notes: notes),
              ));
            },
            child: const Text('Agregar'),
          ),
        ],
        ),
      ),
    ),
  );
  // El cierre de un diálogo es animado; liberar los controladores en el mismo
  // frame puede hacer que TextField los consulte durante su desmontaje.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  quantityController.dispose();
  priceController.dispose();
  notesController.dispose();
}

class _OrderViewState extends State<OrderView> {
  String _status = 'ALL';
  final _searchController = TextEditingController();

  bool get _canCreateOrder =>
      getIt<AccessControl>().allows(AppCapability.createOrders);
  bool get _canEditOrder =>
      getIt<AccessControl>().allows(AppCapability.editOrders);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchOrders(OrderState state, {bool clear = false}) {
    if (clear) {
      _searchController.clear();
    }
    context.read<OrderBloc>().add(
      LoadOrders(
        filter: state.dateFilter,
        fromDate: state.fromDate,
        toDate: state.toDate,
        orderStatus: state.orderStatus,
        searchQuery: _searchController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<OrderBloc, OrderState>(
    listener: (context, state) {
      if (state.errorMessage != null && state.status == OrderStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        context.read<OrderBloc>().add(const ClearOrderError());
      }
      if (state.savedOrder != null || state.deleted == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operación realizada correctamente')),
        );
        context.read<OrderBloc>().add(const ClearOrderAction());
      }
    },
    builder: (context, state) {
      final orders = state.orders;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const XsAppBar(title: 'Órdenes y ventas', backIcon: false),
        endDrawer: const XsDrawer(),
        floatingActionButton: _canCreateOrder
            ? FloatingActionButton.extended(
                onPressed: state.isCashSessionOpen == true
                    ? () => _openOrderForm(context)
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Nueva orden'),
              )
            : null,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<OrderBloc>().add(
                LoadOrders(
                  filter: state.dateFilter,
                  fromDate: state.fromDate,
                  toDate: state.toDate,
                  orderStatus: state.orderStatus,
                  searchQuery: state.searchQuery,
                ),
              );
              if (_canCreateOrder || _canEditOrder) {
                context.read<OrderBloc>().add(const LoadOrderProducts());
              }
              if (_canCreateOrder) {
                context.read<OrderBloc>().add(const CheckOpenCashSession());
              }
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
              children: [
                if (_canCreateOrder && state.isCashSessionOpen != true) ...[
                  _CashSessionRequiredCard(
                    isChecking: state.isCashSessionOpen == null,
                    onOpenCashSession: () =>
                        Navigator.pushNamed(
                          context,
                          AppRoutes.cashSession,
                        ).then(
                          (_) => context.read<OrderBloc>().add(
                            const CheckOpenCashSession(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchOrders(state),
                  decoration: InputDecoration(
                    labelText: 'Buscar por número o mesa',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Buscar órdenes',
                          onPressed: () => _searchOrders(state),
                          icon: const Icon(Icons.search_rounded),
                        ),
                        IconButton(
                          tooltip: 'Limpiar búsqueda',
                          onPressed: () => _searchOrders(state, clear: true),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _OrderDateFilters(
                  selected: state.dateFilter,
                  fromDate: state.fromDate,
                  toDate: state.toDate,
                  orderStatus: state.orderStatus,
                  searchQuery: state.searchQuery,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(
                      value: 'ALL',
                      child: Text('Todos los estados'),
                    ),
                    DropdownMenuItem(
                      value: 'PENDING',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'PREPARING',
                      child: Text('En preparación'),
                    ),
                    DropdownMenuItem(value: 'READY', child: Text('Lista')),
                    DropdownMenuItem(
                      value: 'COMPLETED',
                      child: Text('Completada'),
                    ),
                    DropdownMenuItem(
                      value: 'CANCELLED',
                      child: Text('Cancelada'),
                    ),
                  ],
                  onChanged: (value) {
                    final selectedStatus = value ?? 'ALL';
                    setState(() => _status = selectedStatus);
                    context.read<OrderBloc>().add(
                      LoadOrders(
                        filter: state.dateFilter,
                        fromDate: state.fromDate,
                        toDate: state.toDate,
                        orderStatus: selectedStatus,
                        searchQuery: state.searchQuery,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                if (orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: Text('No se encontraron órdenes.')),
                  )
                else
                  ...orders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderCard(
                        order: order,
                        onTap: () =>
                            _showOrderDetail(context, order, state.products),
                      ),
                    ),
                  ),
                if (state.hasMoreOrders || state.isLoadingMoreOrders)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: state.isLoadingMoreOrders
                            ? null
                            : () => context.read<OrderBloc>().add(
                                const LoadMoreOrders(),
                              ),
                        icon: state.isLoadingMoreOrders
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more_rounded),
                        label: Text(
                          state.isLoadingMoreOrders
                              ? 'Cargando...'
                              : 'Ver más órdenes',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _OrderDateFilters extends StatelessWidget {
  const _OrderDateFilters({
    required this.selected,
    required this.fromDate,
    required this.toDate,
    required this.orderStatus,
    required this.searchQuery,
  });

  final OrderDateFilter selected;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String orderStatus;
  final String searchQuery;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _chip(context, 'Todos', OrderDateFilter.all),
        _chip(context, 'Hoy', OrderDateFilter.today),
        _chip(context, 'Esta semana', OrderDateFilter.week),
        _chip(context, 'Este mes', OrderDateFilter.month),
        _chip(context, 'Personalizado', OrderDateFilter.custom),
      ],
    ),
  );

  Widget _chip(BuildContext context, String label, OrderDateFilter filter) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected == filter,
          onSelected: (_) => _select(context, filter),
        ),
      );

  Future<void> _select(BuildContext context, OrderDateFilter filter) async {
    final now = DateUtils.dateOnly(DateTime.now());
    DateTime? from;
    DateTime? to;
    if (filter == OrderDateFilter.today) {
      from = now;
      to = now;
    } else if (filter == OrderDateFilter.week) {
      from = now.subtract(Duration(days: now.weekday - 1));
      to = now;
    } else if (filter == OrderDateFilter.month) {
      from = DateTime(now.year, now.month);
      to = now;
    } else if (filter == OrderDateFilter.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: now,
        initialDateRange: fromDate != null && toDate != null
            ? DateTimeRange(start: fromDate!, end: toDate!)
            : null,
      );
      if (range == null || !context.mounted) return;
      from = DateUtils.dateOnly(range.start);
      to = DateUtils.dateOnly(range.end);
    }
    if (!context.mounted) return;
    context.read<OrderBloc>().add(
      LoadOrders(
        filter: filter,
        fromDate: from,
        toDate: to,
        orderStatus: orderStatus,
        searchQuery: searchQuery,
      ),
    );
  }
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: .25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  _StatusChip(status: order.status ?? 'PENDING'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_typeLabel(order.orderType)}${order.tableNumber?.isNotEmpty == true ? ' · ${order.tableNumber}' : ''}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${order.items.where((item) => item.status != 'CANCELLED').length} producto(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    'S/ ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void _showOrderDetail(
  BuildContext context,
  Order order,
  List<Product> products,
) {
  final quickServeSelected = <int>{};
  if (order.id != null &&
      getIt<AccessControl>().allows(AppCapability.viewOrderItemHistory)) {
    context.read<OrderBloc>().add(LoadOrderIncidents(order.id!));
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<OrderBloc>(),
      child: BlocListener<OrderBloc, OrderState>(
        listenWhen: (previous, current) =>
            previous.deleted != true && current.deleted == true,
        listener: (_, __) {
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        },
        child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .76,
        maxChildSize: .93,
        builder: (_, controller) => StatefulBuilder(
        builder: (_, setSheetState) => BlocBuilder<OrderBloc, OrderState>(
        builder: (_, state) {
          Order currentOrder = order;
          for (final candidate in state.orders) {
            if (candidate.id == order.id) {
              currentOrder = candidate;
              break;
            }
          }
          if (state.savedOrder?.id == order.id) {
            currentOrder = state.savedOrder!;
          }
          final selectableIds = currentOrder.items
              .where((item) =>
                  item.id != null &&
                  item.status != 'CANCELLED' &&
                  item.status != 'SERVED')
              .map((item) => item.id!)
              .toSet();
          quickServeSelected.removeWhere((id) => !selectableIds.contains(id));
          return ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  currentOrder.orderNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusChip(status: currentOrder.status ?? 'PENDING'),
            ],
          ),
          const SizedBox(height: 4),
          Text(_typeLabel(currentOrder.orderType)),
          if (currentOrder.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(currentOrder.notes!),
          ],
          if (currentOrder.status != 'CANCELLED') const Divider(height: 32),
          if (currentOrder.status == 'CANCELLED')
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 34),
                    SizedBox(height: 8),
                    Text(
                      'Esta orden fue cancelada.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text('No tiene productos ni importe pendiente.'),
                  ],
                ),
              ),
            ),
          if (currentOrder.status == 'CANCELLED' &&
              currentOrder.items.isNotEmpty) ...[
            const Text(
              'Detalle de productos cancelados',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ...currentOrder.items.map(
              (item) => Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.redAccent,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(_productName(products, item.productId)),
                        ),
                        Text(
                          'S/ ${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              '${_quantity(item.quantity)} × S/ ${item.unitPrice.toStringAsFixed(2)}',
                            ),
                            const _OrderItemStatusBadge(status: 'CANCELLED'),
                          ],
                        ),
                        if (item.notes?.trim().isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Nota: ${item.notes!.trim()}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const _DashedItemDivider(),
                ],
              ),
            ),
          ],
          if (currentOrder.status != 'CANCELLED')
            ...currentOrder.items.where((item) => item.status != 'CANCELLED').map(
            (item) {
              final canSelectForQuickServe =
                  currentOrder.status != 'COMPLETED' &&
                  currentOrder.id != null &&
                  item.id != null &&
                  item.status != 'SERVED' &&
                  getIt<AccessControl>().allows(
                    AppCapability.correctOrderItemStatus,
                  );
              return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  isThreeLine: true,
                  leading: canSelectForQuickServe
                      ? Checkbox(
                          value: quickServeSelected.contains(item.id),
                          onChanged: (value) => setSheetState(() {
                            if (value == true) {
                              quickServeSelected.add(item.id!);
                            } else {
                              quickServeSelected.remove(item.id);
                            }
                          }),
                        )
                      : item.status == 'SERVED'
                          ? const Tooltip(
                              message: 'Producto servido',
                              child: Icon(
                                Icons.check_box_rounded,
                                color: Colors.teal,
                              ),
                            )
                          : null,
                  title: Row(
                children: [
                  Icon(
                    item.fulfillmentType == 'TAKEAWAY'
                        ? Icons.shopping_bag_outlined
                        : Icons.home_outlined,
                    size: 18,
                    color: item.fulfillmentType == 'TAKEAWAY'
                        ? Colors.deepOrange.shade700
                        : Colors.indigo.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_productName(products, item.productId))),
                  Text(
                    'S/ ${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (state.incidentsOrderId == currentOrder.id &&
                      _hasIncidentForItem(state.incidents, item.id))
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Tooltip(
                        message: 'Producto con incidencia registrada',
                        child: Icon(
                          Icons.assignment_late_outlined,
                          color: Colors.deepOrange,
                          size: 19,
                        ),
                      ),
                    ),
                ],
              ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('${_quantity(item.quantity)} × S/ ${item.unitPrice.toStringAsFixed(2)}'),
                          _OrderItemStatusBadge(status: item.status),
                        ],
                      ),
                      if (item.notes?.trim().isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Nota: ${item.notes!.trim()}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _OrderItemTrailingAction(
                            order: currentOrder,
                            item: item,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const _DashedItemDivider(),
              ],
            );
            },
          ),
          if (currentOrder.status != 'CANCELLED' &&
              currentOrder.status != 'COMPLETED' &&
              currentOrder.id != null &&
              getIt<AccessControl>().allows(AppCapability.correctOrderItemStatus) &&
              currentOrder.items.any((item) =>
                  item.id != null &&
                  item.status != 'CANCELLED' &&
                  item.status != 'SERVED')) ...[
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: quickServeSelected.isEmpty
                  ? null
                  : () async {
                      final itemIds = quickServeSelected.toList();
                      final confirmed = await _confirmQuickServe(
                        context,
                        itemIds.length,
                      );
                      if (!confirmed || !context.mounted) return;
                      setSheetState(quickServeSelected.clear);
                      context.read<OrderBloc>().add(ChangeOrderItemsStatus(
                            currentOrder.id!,
                            itemIds,
                            'CORRECT_TO_SERVED',
                            comment: 'Entrega registrada en lote',
                          ));
                    },
              icon: const Icon(Icons.done_all_outlined),
              label: Text(
                quickServeSelected.isEmpty
                    ? 'Marque productos entregados'
                    : 'Registrar entrega (${quickServeSelected.length})',
              ),
            ),
          ],
          if (currentOrder.status != 'CANCELLED' &&
              currentOrder.status != 'COMPLETED' &&
              currentOrder.id != null &&
              currentOrder.items.any((item) => item.status != 'CANCELLED') &&
              (getIt<AccessControl>().allows(AppCapability.prepareOrderItem) ||
                  getIt<AccessControl>().allows(AppCapability.markOrderItemReady) ||
                  getIt<AccessControl>().allows(AppCapability.serveOrderItem) ||
                  getIt<AccessControl>().allows(AppCapability.correctOrderItemStatus)))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _showBulkStatusDialog(context, currentOrder, products),
                icon: const Icon(Icons.done_all_outlined),
                label: const Text('Actualizar varios'),
              ),
            ),
          if (currentOrder.status != 'CANCELLED' &&
              getIt<AccessControl>().allows(AppCapability.viewOrderItemHistory) &&
              order.id != null) ...[
            const Divider(height: 32),
            const Text('Historial de incidencias', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (state.incidentsOrderId != order.id)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.incidents.isEmpty)
              const Text('No se registraron incidencias.')
            else
              ...state.incidents.map((incident) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.report_problem_outlined),
                    title: Text(
                      '${_incidentResolutionLabel(incident.resolution)} · ${_productName(products, incident.productId)}',
                    ),
                    subtitle: Text(
                      '${incident.reason}${incident.discountAmount > 0 ? ' · S/ ${incident.discountAmount.toStringAsFixed(2)}' : ''}\n'
                      'Estado: ${_incidentStatusLabel(incident.status)}${incident.reportedAt != null ? ' · ${_incidentDate(incident.reportedAt!)}' : ''}',
                    ),
                    isThreeLine: true,
                  )),
          ],
          if (currentOrder.status != 'CANCELLED') const Divider(),
          if (currentOrder.status != 'CANCELLED') Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (currentOrder.incidentDiscount > 0)
                  Text(
                    'Descuento por incidencias: -S/ ${currentOrder.incidentDiscount.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                Text(
                  'Total: S/ ${currentOrder.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (currentOrder.status != 'CANCELLED') const SizedBox(height: 20),
          if (_canEditActiveOrder(currentOrder.status) &&
              currentOrder.items.every((item) => item.status == 'PENDING') &&
              getIt<AccessControl>().allows(AppCapability.editOrders)) ...[
              FilledButton.icon(
                onPressed: () async {
                  final wasSaved = await _openOrderForm(context, order: currentOrder);
                  final sheetNavigator = Navigator.of(sheetContext);
                  if (wasSaved == true && sheetNavigator.mounted) {
                    sheetNavigator.pop();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar orden'),
              ),
              const SizedBox(height: 10),
            ],
          if (_canEditActiveOrder(currentOrder.status) &&
              getIt<AccessControl>().allows(AppCapability.addOrderItem)) ...[
              FilledButton.tonalIcon(
                onPressed: () => _showAddOrderItem(context, currentOrder, products),
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Agregar producto'),
              ),
              const SizedBox(height: 10),
            ],
          if (currentOrder.status == 'PENDING' &&
              getIt<AccessControl>().allows(AppCapability.deleteOrders))
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, currentOrder),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar orden'),
            ),
          if (state.status != OrderStatus.loading &&
              currentOrder.status != 'COMPLETED' &&
              currentOrder.status != 'CANCELLED' &&
              _isOrderReadyToCharge(currentOrder) &&
              getIt<AccessControl>().allows(AppCapability.viewSales) &&
              getIt<AccessControl>().allows(AppCapability.createSales)) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.pushNamed(AppRoutes.sales, arguments: currentOrder).then((
                  _,
                ) {
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
          if (currentOrder.status != 'COMPLETED' &&
              currentOrder.status != 'CANCELLED' &&
              currentOrder.items.every((item) =>
                  item.status == 'PENDING' || item.status == 'CANCELLED') &&
              getIt<AccessControl>().allows(AppCapability.updateOrderStatus)) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _confirmCancel(context, currentOrder),
              child: const Text('Cancelar orden'),
            ),
          ],
        ],
          );
        },
        ),
        ),
      ),
      ),
    ),
  );
}

Future<bool> _confirmQuickServe(BuildContext context, int count) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar entrega'),
      content: Text(
        count == 1
            ? '¿Marcar este producto como servido?'
            : '¿Marcar $count productos como servidos?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Confirmar entrega'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<void> _showBulkStatusDialog(
  BuildContext context,
  Order order,
  List<Product> products,
) async {
  final bloc = context.read<OrderBloc>();
  final selected = <int>{};
  final commentController = TextEditingController();
  var targetStatus = 'PREPARING';
  var serveDirectly = false;
  final access = getIt<AccessControl>();
  final availableStatuses = <String>{
    if (access.allows(AppCapability.prepareOrderItem)) 'PREPARING',
    if (access.allows(AppCapability.markOrderItemReady)) 'READY',
    if (access.allows(AppCapability.serveOrderItem)) 'SERVED',
    if (access.allows(AppCapability.correctOrderItemStatus)) ...{
      'RESTORE_PREVIOUS',
      'CORRECT_TO_PENDING',
      'CORRECT_TO_PREPARING',
      'CORRECT_TO_READY',
      'CORRECT_TO_SERVED',
    },
  };
  if (availableStatuses.isEmpty || order.id == null) return;
  targetStatus = availableStatuses.contains('PREPARING')
      ? 'PREPARING'
      : availableStatuses.first;

  List<OrderItem> eligibleItems() => order.items.where((item) {
        if (item.id == null || item.status == 'CANCELLED') return false;
        if (serveDirectly) return item.status == 'PENDING';
        return switch (targetStatus) {
          'PREPARING' => item.status == 'PENDING',
          'READY' => item.status == 'PREPARING',
          'SERVED' => item.status == 'READY',
          'RESTORE_PREVIOUS' => item.status == 'PREPARING' ||
              item.status == 'READY' ||
              item.status == 'SERVED',
          'CORRECT_TO_PENDING' => item.status != 'PENDING',
          'CORRECT_TO_PREPARING' => item.status != 'PREPARING',
          'CORRECT_TO_READY' => item.status != 'READY',
          'CORRECT_TO_SERVED' => item.status != 'SERVED',
          _ => false,
        };
      }).toList();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: bloc,
      child: StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: const Text('Actualizar varios productos'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text('1. Elija una acción.  2. Marque los productos compatibles.'),
                const SizedBox(height: 8),
                if (!serveDirectly)
                  DropdownButtonFormField<String>(
                    value: targetStatus,
                    decoration: const InputDecoration(labelText: 'Acción a aplicar'),
                    items: [
                      if (access.allows(AppCapability.prepareOrderItem))
                        const DropdownMenuItem(value: 'PREPARING', child: Text('Pasar a En preparación')),
                      if (access.allows(AppCapability.markOrderItemReady))
                        const DropdownMenuItem(value: 'READY', child: Text('Marcar como Listo')),
                      if (access.allows(AppCapability.serveOrderItem))
                        const DropdownMenuItem(value: 'SERVED', child: Text('Marcar como Servido')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem<String>(
                          enabled: false,
                          child: Text('— Correcciones —'),
                        ),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'RESTORE_PREVIOUS', child: Text('Restaurar estado anterior')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_PENDING', child: Text('Corregir: Pendiente')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_PREPARING', child: Text('Corregir: En preparación')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_READY', child: Text('Corregir: Listo')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_SERVED', child: Text('Corregir: Servido')),
                    ],
                    onChanged: (value) => setState(() {
                      if (value == null || !availableStatuses.contains(value)) return;
                      targetStatus = value;
                      selected.clear();
                    }),
                  ),
                if (targetStatus == 'RESTORE_PREVIOUS')
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Cada producto volverá al estado que tenía antes de su último cambio. No modifica stock ni importes.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                    ),
                  ),
                if (targetStatus.startsWith('CORRECT_TO_'))
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Corrección operativa: actualiza solo el estado. No modifica stock ni importes.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                    ),
                  ),
                if (targetStatus == 'RESTORE_PREVIOUS' ||
                    targetStatus.startsWith('CORRECT_TO_'))
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextField(
                      controller: commentController,
                      maxLength: 500,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Comentario de corrección (opcional)',
                        hintText: 'Ej.: se marcó por error como servido',
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Productos disponibles (${eligibleItems().length})', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (eligibleItems().isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => selected
                          ..clear()
                          ..addAll(eligibleItems().map((item) => item.id!))),
                        child: const Text('Todos'),
                      ),
                  ],
                ),
                if (eligibleItems().isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('No hay productos con el estado requerido para esta acción.'),
                  ),
                ...eligibleItems().map((item) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selected.contains(item.id),
                      onChanged: (value) => setState(() => value == true ? selected.add(item.id!) : selected.remove(item.id)),
                      title: Text(_productName(products, item.productId)),
                      subtitle: Text('${_quantity(item.quantity)} · ${_itemStatusLabel(item.status)}'),
                    )),
                if (access.allows(AppCapability.correctOrderItemStatus))
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: serveDirectly,
                    title: const Text('Servir directamente'),
                    subtitle: const Text('Solo muestra productos pendientes.'),
                    onChanged: (value) => setState(() {
                      serveDirectly = value ?? false;
                      selected.clear();
                    }),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton.icon(
              onPressed: selected.isEmpty ? null : () {
                Navigator.pop(dialogContext);
                bloc.add(ChangeOrderItemsStatus(
                  order.id!,
                  selected.toList(),
                  serveDirectly ? 'SERVED' : targetStatus,
                  comment: commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                ));
              },
              icon: const Icon(Icons.done_all_outlined),
              label: Text('Aplicar a ${selected.length}'),
            ),
          ],
        ),
      ),
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  commentController.dispose();
}

String _incidentResolutionLabel(String resolution) => switch (resolution) {
  'CANCEL_NO_CHARGE' => 'Producto no cobrado',
  'REPLACE' => 'Reposición',
  'DISCOUNT' => 'Descuento',
  _ => resolution,
};

String _incidentStatusLabel(String status) => switch (status) {
  'SUPERSEDED' => 'Sustituido por una compensación posterior',
  'APROVED' || 'APPROVED' => 'Aprobado',
  _ => status,
};

String _incidentDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

void _confirmDelete(BuildContext context, Order order) {
  if (!getIt<AccessControl>().allows(AppCapability.deleteOrders)) return;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar orden'),
      content: Text(
        '¿Eliminar ${order.orderNumber}? Esta acción solo es válida para órdenes pendientes.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.read<OrderBloc>().add(DeleteOrder(order.id!));
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

void _confirmCancel(BuildContext context, Order order) {
  if (!getIt<AccessControl>().allows(AppCapability.updateOrderStatus)) return;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: const Text('¿Cancelar orden?'),
      content: Text(
        'Se liberará el stock reservado de ${order.orderNumber}. Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.read<OrderBloc>().add(
              ChangeOrderStatus(order.id!, 'CANCELLED'),
            );
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Sí, cancelar'),
        ),
      ],
    ),
  );
}

Future<bool?> _openOrderForm(BuildContext context, {Order? order}) async {
  final required = order == null
      ? AppCapability.createOrders
      : AppCapability.editOrders;
  if (!getIt<AccessControl>().allows(required)) return null;
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
        const SnackBar(
          content: Text(
            'No se pudo actualizar la disponibilidad de productos.',
          ),
        ),
      );
    }
    return null;
  }
}

class _OrderFormDialog extends StatefulWidget {
  final Order? order;
  final List<Product> products;
  const _OrderFormDialog({this.order, required this.products});
  @override
  State<_OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<_OrderFormDialog> {
  late final TextEditingController numberController;
  late final TextEditingController tableController;
  late final TextEditingController notesController;
  late String type;
  late List<OrderItem> items;
  late List<Product> availableProducts;
  final key = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    final o = widget.order;
    numberController = TextEditingController(text: o?.orderNumber ?? '');
    tableController = TextEditingController(text: o?.tableNumber);
    notesController = TextEditingController(text: o?.notes);
    type = o?.orderType ?? 'DINE_IN';
    items = [...?o?.items];
    availableProducts = [...widget.products];
  }

  @override
  void dispose() {
    numberController.dispose();
    tableController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<OrderBloc, OrderState>(
    listenWhen: (previous, current) =>
        previous.savedOrder == null && current.savedOrder != null,
    listener: (context, state) {
      final savedOrder = state.savedOrder;
      final savedThisOrder = savedOrder != null &&
          (widget.order == null || savedOrder.id == widget.order!.id);
      if (savedThisOrder && context.mounted) {
        Navigator.of(context).pop(true);
      }
    },
    child: AlertDialog(
    title: Text(widget.order == null ? 'Nueva orden' : 'Editar orden'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.order == null)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('El número de orden se generará al guardar.'),
                )
              else
                TextFormField(
                  controller: numberController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Número de orden',
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'DINE_IN', child: Text('En local')),
                  DropdownMenuItem(
                    value: 'TAKEAWAY',
                    child: Text('Para llevar'),
                  ),
                  DropdownMenuItem(value: 'DELIVERY', child: Text('Entrega')),
                ],
                onChanged: (v) => setState(() => type = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tableController,
                decoration: const InputDecoration(
                  labelText: 'Mesa o referencia',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notas'),
              ),
              const Divider(height: 30),
              Row(
                children: [
                  const Text(
                    'Productos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (widget.order == null || widget.order?.status == 'PENDING')
                    TextButton.icon(
                      onPressed: availableProducts.isEmpty ? null : _addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                    ),
                ],
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Agregue al menos un producto.'),
                ),
              ...items.asMap().entries.map(
                (entry) => _EditableItem(
                  item: entry.value,
                  productName: _productName(
                    availableProducts,
                    entry.value.productId,
                  ),
                  referencePrice: _productCurrentPrice(
                    availableProducts,
                    entry.value.productId,
                  ),
                  product: _productById(
                    availableProducts,
                    entry.value.productId,
                  ),
                  availableQuantity: _maximumQuantityForProduct(
                    entry.value.productId,
                  ),
                  onChanged: (item) => setState(() => items[entry.key] = item),
                  onDelete: () => setState(() => items.removeAt(entry.key)),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: S/ ${items.fold<double>(0, (sum, item) => sum + item.subtotal).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.order != null &&
                  widget.order!.status != 'COMPLETED' &&
                  widget.order!.status != 'CANCELLED' &&
                  !_isOrderReadyToCharge(widget.order!))
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('El cobro estará disponible cuando todos los productos activos estén servidos.'),
            ),
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
      FilledButton(onPressed: _submit, child: const Text('Guardar')),
    ],
    ),
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
              onLoadMore: () => sheetContext.read<OrderBloc>().add(
                const LoadMoreOrderProducts(),
              ),
              onSearchChanged: (query) => sheetContext.read<OrderBloc>().add(
                SearchOrderProducts(query),
              ),
            ),
          ),
        ),
      ),
    );
    if (selected == null) return;
    if (selected.availableStock == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El producto no tiene stock disponible.')),
      );
      return;
    }
    final index = items.indexWhere((item) => item.productId == selected.id);
    final maximumQuantity = _maximumQuantityForProduct(selected.id);
    if (index >= 0 && items[index].quantity + 1 > maximumQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solo hay $maximumQuantity unidad(es) disponible(s).'),
        ),
      );
      return;
    }
    setState(() {
      if (!availableProducts.any((product) => product.id == selected.id)) {
        availableProducts.add(selected);
      }
      if (index >= 0) {
        final old = items[index];
        items[index] = OrderItem(
          id: old.id,
          productId: old.productId,
          quantity: old.quantity + 1,
          unitPrice: old.unitPrice,
          notes: old.notes,
          fulfillmentType: old.fulfillmentType,
          status: old.status,
        );
      } else {
        items.add(
          OrderItem(
            productId: selected.id,
            quantity: 1,
            unitPrice: selected.promoPrice ?? selected.basePrice,
            fulfillmentType: type == 'TAKEAWAY' ? 'TAKEAWAY' : 'DINE_IN',
          ),
        );
      }
    });
  }

  void _submit() {
    final required = widget.order == null
        ? AppCapability.createOrders
        : AppCapability.editOrders;
    if (!getIt<AccessControl>().allows(required)) return;
    if (!(key.currentState?.validate() ?? false)) return;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La orden debe incluir al menos un producto.'),
        ),
      );
      return;
    }
    for (final item in items) {
      final availableStock = _maximumQuantityForProduct(item.productId);
      if (availableStock < 0 || item.quantity > availableStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La cantidad de ${_productName(availableProducts, item.productId)} supera el stock disponible.',
            ),
          ),
        );
        return;
      }
    }
    context.read<OrderBloc>().add(
      SaveOrder(
        Order(
          id: widget.order?.id,
          orderNumber: numberController.text.trim(),
          orderType: type,
          tableNumber: _nullIfBlank(tableController.text),
          notes: _nullIfBlank(notesController.text),
          items: items,
          status: widget.order?.status,
        ),
      ),
    );
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

double? _productCurrentPrice(List<Product> products, int id) {
  for (final product in products) {
    if (product.id == id) return product.promoPrice ?? product.basePrice;
  }
  return null;
}

Product? _productById(List<Product> products, int id) {
  for (final product in products) {
    if (product.id == id) return product;
  }
  return null;
}

class _EditableItem extends StatelessWidget {
  final OrderItem item;
  final String productName;
  final double? referencePrice;
  final Product? product;
  final int availableQuantity;
  final ValueChanged<OrderItem> onChanged;
  final VoidCallback onDelete;

  const _EditableItem({
    required this.item,
    required this.productName,
    required this.referencePrice,
    required this.product,
    required this.availableQuantity,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(productName)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.close)),
            ],
          ),
          Text(
            product == null
                ? 'Disponible: $availableQuantity'
                : 'Stock: ${product!.totalStock} | Reservado: ${product!.reservedStock} | Disponible: ${product!.availableStock}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              Expanded(
                child: _NumberInput(
                  label: 'Cantidad',
                  initial: item.quantity,
                  maximum: availableQuantity.toDouble(),
                  wholeNumber: true,
                  onChanged: (v) => onChanged(
                    OrderItem(
                      id: item.id,
                      productId: item.productId,
                      quantity: v,
                      unitPrice: item.unitPrice,
                      fulfillmentType: item.fulfillmentType,
                      status: item.status,
                      notes: item.notes,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberInput(
                  label: 'Precio',
                  initial: item.unitPrice,
                  onChanged: (v) => onChanged(
                    OrderItem(
                      id: item.id,
                      productId: item.productId,
                      quantity: item.quantity,
                      unitPrice: v,
                      fulfillmentType: item.fulfillmentType,
                      status: item.status,
                      notes: item.notes,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (referencePrice != null) ...[
            const SizedBox(height: 4),
            _PriceVariationHint(
              referencePrice: referencePrice!,
              selectedPrice: item.unitPrice,
            ),
          ],
          TextFormField(
            initialValue: item.notes,
            maxLines: 2,
            maxLength: 255,
            decoration: const InputDecoration(
              labelText: 'Notas del producto',
              hintText: 'Ej.: con leche, dos azúcares',
            ),
            onChanged: (value) => onChanged(
              OrderItem(
                id: item.id,
                productId: item.productId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                notes: _nullIfBlank(value),
                fulfillmentType: item.fulfillmentType,
                status: item.status,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Subtotal: S/ ${item.subtotal.toStringAsFixed(2)}'),
          ),
        ],
      ),
    ),
  );
}

class _NumberInput extends StatelessWidget {
  final String label;
  final double initial;
  final double? maximum;
  final bool wholeNumber;
  final ValueChanged<double> onChanged;
  const _NumberInput({
    required this.label,
    required this.initial,
    this.maximum,
    this.wholeNumber = false,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: wholeNumber ? initial.toInt().toString() : initial.toStringAsFixed(2),
    keyboardType: TextInputType.numberWithOptions(decimal: !wholeNumber),
    inputFormatters: wholeNumber
        ? [FilteringTextInputFormatter.digitsOnly]
        : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(labelText: label, isDense: true),
    validator: (value) {
      final number = double.tryParse(value ?? '');
      if (number == null || number <= 0)
        return 'Ingrese un valor mayor que cero';
      if (wholeNumber && number % 1 != 0) return 'Ingrese un número entero';
      if (maximum != null && number > maximum!)
        return 'Máximo: ${maximum!.toInt()}';
      return null;
    },
    onChanged: (v) {
      final number = double.tryParse(v);
      if (number != null &&
          number > 0 &&
          (!wholeNumber || number % 1 == 0)) {
        onChanged(number);
      }
    },
  );
}

class _PriceVariationHint extends StatelessWidget {
  const _PriceVariationHint({
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
      'Precio vigente: S/ ${referencePrice.toStringAsFixed(2)} · $prefix S/ ${difference.abs().toStringAsFixed(2)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
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

String? _nullIfBlank(String value) =>
    value.trim().isEmpty ? null : value.trim();
String _quantity(double value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toString();
String _typeLabel(String type) => switch (type) {
  'DINE_IN' => 'En local',
  'TAKEAWAY' => 'Para llevar',
  'DELIVERY' => 'Entrega',
  _ => type,
};
String _statusLabel(String status) => switch (status) {
  'PENDING' => 'PENDIENTE',
  'PREPARING' => 'EN PREPARACIÓN',
  'READY' => 'LISTA',
  'COMPLETED' => 'COMPLETADA',
  'CANCELLED' => 'CANCELADA',
  _ => status,
};
bool _canEditActiveOrder(String? status) =>
    status == 'PENDING' || status == 'PREPARING' || status == 'READY';
Color _statusColor(String? status) => switch (status) {
  'PENDING' => Colors.orange,
  'PREPARING' => Colors.blue,
  'READY' => Colors.green,
  'COMPLETED' => Colors.teal,
  'CANCELLED' => Colors.red,
  _ => AppColors.primary,
};
String? _nextStatus(String? status) => switch (status) {
  'PENDING' => 'PREPARING',
  'PREPARING' => 'READY',
  _ => null,
};

AppCapability? _capabilityForItemStatus(String status) => switch (status) {
  'PREPARING' => AppCapability.prepareOrderItem,
  'READY' => AppCapability.markOrderItemReady,
  'SERVED' => AppCapability.serveOrderItem,
  _ => null,
};

String? _nextItemStatus(String status) => switch (status) {
  'PENDING' => 'PREPARING',
  'PREPARING' => 'READY',
  'READY' => 'SERVED',
  _ => null,
};

String _itemStatusLabel(String status) => switch (status) {
  'PENDING' => 'Pendiente',
  'PREPARING' => 'Preparando',
  'READY' => 'Listo',
  'SERVED' => 'Servido',
  'CANCELLED' => 'Cancelado',
  _ => status,
};

Color _itemStatusColor(String status) => switch (status) {
  'PENDING' => Colors.orange.shade800,
  'PREPARING' => Colors.blue.shade700,
  'READY' => Colors.green.shade700,
  'SERVED' => Colors.teal.shade700,
  'CANCELLED' => Colors.red.shade700,
  _ => AppColors.primary,
};

String _itemStatusActionLabel(String status) => switch (status) {
  'PREPARING' => 'Preparar',
  'READY' => 'Listo',
  'SERVED' => 'Servir',
  _ => status,
};

bool _isOrderReadyToCharge(Order order) {
  final activeItems = order.items.where((item) => item.status != 'CANCELLED');
  return activeItems.isNotEmpty && activeItems.every((item) => item.status == 'SERVED');
}

bool _hasIncidentForItem(List<OrderItemIncident> incidents, int? itemId) =>
    itemId != null && incidents.any((incident) => incident.orderItemId == itemId);
