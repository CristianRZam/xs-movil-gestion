import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/authorization/permission_sync_service.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'dart:async';

import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_status_history.dart';
import 'package:app_movil_sistema/features/order/domain/usecases/order_usecases.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_bloc.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_event.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_state.dart';
import 'package:app_movil_sistema/features/order/presentation/pages/order_composer_page.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_lookup.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/data/services/product_lookup_service.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-async-lookup-field.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-filter-button.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

void _showOrderFlash(
  BuildContext context,
  FlashMessageType type,
  String title, [
  String message = '',
]) => FlashMessage.show(
  context,
  type: type,
  title: title,
  message: message,
);

class OrderView extends StatefulWidget {
  const OrderView({super.key});
  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderItemTrailingAction extends StatelessWidget {
  const _OrderItemTrailingAction({
    required this.order,
    required this.item,
    required this.isIncidentLocked,
    required this.onSaved,
  });

  final Order order;
  final OrderItem item;
  final bool isIncidentLocked;
  final void Function(Order order) onSaved;

  @override
  Widget build(BuildContext context) {
    final canEditOrder = getIt<AccessControl>().allows(AppCapability.editOrders);
    final isActiveOrder = order.status != 'COMPLETED' && order.status != 'CANCELLED';
    final nextStatus = _nextItemStatus(item.status);
    final canUpdate = canEditOrder &&
        isActiveOrder &&
        !isIncidentLocked &&
        nextStatus != null &&
        item.id != null &&
        order.id != null;
    final canReportIncident = canEditOrder &&
        !isIncidentLocked &&
        isActiveOrder && item.status == 'SERVED' && item.id != null && order.id != null &&
        getIt<AccessControl>().allows(AppCapability.reportOrderIncident) &&
        getIt<AccessControl>().allows(AppCapability.approveOrderCompensation);
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
            onPressed: () async {
              final completer = Completer<Order>();
              context.read<OrderBloc>().add(
                ChangeOrderItemStatus(
                  order.id!,
                  item.id!,
                  nextStatus!,
                  completer: completer,
                ),
              );
              try {
                onSaved(await completer.future);
              } catch (_) {
                // El Bloc muestra el mensaje global de error.
              }
            },
          ),
        if (canReportIncident)
          IconButton(
            tooltip: 'Registrar incidencia',
            visualDensity: VisualDensity.compact,
            color: Colors.red.shade700,
            icon: const Icon(Icons.add_alert_outlined, size: 20),
            onPressed: () => _showIncidentDialog(
              context,
              order.id!,
              item.id!,
              onSaved: onSaved,
            ),
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

Future<void> _showIncidentDialog(
  BuildContext context,
  int orderId,
  int itemId, {
  required void Function(Order order) onSaved,
}) async {
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
          FilledButton(onPressed: () async {
            final incidentReason = reason.text.trim();
            final amount = double.tryParse(discount.text);
            if (incidentReason.isEmpty || (resolution == 'DISCOUNT' && (amount == null || amount <= 0))) return;
            Navigator.pop(dialogContext);
            final completer = Completer<Order>();
            context.read<OrderBloc>().add(ReportOrderItemIncident(
              orderId,
              itemId,
              resolution,
              incidentReason,
              discountAmount: amount,
              completer: completer,
            ));
            try {
              onSaved(await completer.future);
            } catch (_) {
              // El BLoC ya muestra el mensaje de error global correspondiente.
            }
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
  void Function(Order order) onSaved,
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
            onPressed: () async {
              final comment = reason.text.trim();
              if (comment.isEmpty) return;
              Navigator.pop(dialogContext);
              final completer = Completer<Order>();
              context.read<OrderBloc>().add(CancelPendingOrderItem(
                    orderId,
                    itemId,
                    comment: comment,
                    stockDisposition: stockDisposition,
                    completer: completer,
                  ));
              try {
                onSaved(await completer.future);
              } catch (_) {
                // El Bloc notifica el error mediante el toast global.
              }
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

Future<void> _showEditPendingOrderItemDialog(
  BuildContext context,
  int orderId,
  OrderItem item,
  int maximumQuantity,
  Product? cachedProduct,
  {required void Function(Order order) onSaved}
) async {
  var refreshedProduct = cachedProduct;
  var refreshedMaximumQuantity = maximumQuantity;
  if (cachedProduct != null) {
    final result = await getIt<GetProductViewUseCase>()(
      ProductViewRequest(code: cachedProduct.code, size: 1, status: true),
    );
    result.fold((_) {}, (view) {
      for (final candidate in view.products) {
        if (candidate.id != item.productId) continue;
        refreshedProduct = candidate;
        refreshedMaximumQuantity =
            candidate.availableStock + item.quantity.toInt();
        break;
      }
    });
  }
  if (!context.mounted) return;
  final quantity = TextEditingController(text: _quantity(item.quantity));
  final notes = TextEditingController(text: item.notes ?? '');
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Editar producto pendiente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: quantity,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Cantidad',
              helperText: refreshedProduct == null
                  ? 'Máximo disponible: $refreshedMaximumQuantity'
                  : 'Stock disponible ahora: ${refreshedProduct!.availableStock} · Máximo para esta orden: $refreshedMaximumQuantity',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notes,
            maxLength: 255,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nota (opcional)',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            final value = int.tryParse(quantity.text);
            if (value == null ||
                value <= 0 ||
                value > refreshedMaximumQuantity) {
              _showOrderFlash(
                dialogContext,
                FlashMessageType.warning,
                'Cantidad no válida',
                'Ingrese una cantidad entre 1 y $refreshedMaximumQuantity.',
              );
              return;
            }
            final completer = Completer<Order>();
            context.read<OrderBloc>().add(
              UpdatePendingOrderItem(
                orderId,
                item.id!,
                OrderItem(
                  id: item.id,
                  productId: item.productId,
                  productName: item.productName,
                  quantity: value.toDouble(),
                  unitPrice: item.unitPrice,
                  notes: _nullIfBlank(notes.text),
                  fulfillmentType: item.fulfillmentType,
                  status: item.status,
                  createdAt: item.createdAt,
                  modifiedAt: item.modifiedAt,
                ),
                completer: completer,
              ),
            );
            try {
              final updatedOrder = await completer.future;
              if (!dialogContext.mounted) return;
              onSaved(updatedOrder);
              Navigator.pop(dialogContext);
            } catch (_) {
              if (!dialogContext.mounted) return;
              _showOrderFlash(
                dialogContext,
                FlashMessageType.error,
                'No se pudo actualizar el producto',
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  quantity.dispose();
  notes.dispose();
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
            categories: state.productCategories,
            selectedCategoryIds: state.selectedProductCategoryIds,
            availableOnly: state.availableProductsOnly,
            searchQuery: state.productSearchQuery,
            hasMore: state.hasMoreProducts,
            isLoadingMore: state.isLoadingMoreProducts,
            onLoadMore: () => sheetContext.read<OrderBloc>().add(const LoadMoreOrderProducts()),
            onSearchChanged: (query) => sheetContext.read<OrderBloc>().add(SearchOrderProducts(query)),
            onFiltersChanged: (categoryIds, availableOnly) =>
                sheetContext.read<OrderBloc>().add(
                  FilterOrderProducts(
                    categoryIds: categoryIds,
                    availableOnly: availableOnly,
                  ),
                ),
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
  String fulfillmentType = switch (order.orderType) {
    'TAKEAWAY' => 'TAKEAWAY',
    'DELIVERY' => 'DELIVERY',
    _ => 'DINE_IN',
  };
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
                DropdownMenuItem(value: 'DELIVERY', child: Text('Entrega')),
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
                _showOrderFlash(
                  context,
                  FlashMessageType.warning,
                  'Revise los datos del producto',
                  'Verifique cantidad, disponibilidad y precio.',
                );
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
        productId: state.productId,
        productName: state.productName,
      ),
    );
  }

  void _openFilters(OrderState state) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _OrderFiltersSheet(
        state: state,
        onApply: (filter, fromDate, toDate, status, product) {
          context.read<OrderBloc>().add(
            LoadOrders(
              filter: filter,
              fromDate: fromDate,
              toDate: toDate,
              orderStatus: status,
              searchQuery: _searchController.text,
              productId: product?.id,
              productName: product?.name,
            ),
          );
          Navigator.of(sheetContext).pop();
        },
        onClear: () {
          context.read<OrderBloc>().add(
            LoadOrders(
              searchQuery: _searchController.text,
              productId: null,
              productName: null,
            ),
          );
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: getIt<AccessControl>(),
    builder: (_, __) => BlocConsumer<OrderBloc, OrderState>(
    listener: (context, state) {
      if (state.errorMessage != null && state.status == OrderStatus.failure) {
        _showOrderFlash(
          context,
          FlashMessageType.error,
          'No se pudo completar la operación',
          state.errorMessage!,
        );
        context.read<OrderBloc>().add(const ClearOrderError());
      }
      if (state.successMessage != null) {
        _showOrderFlash(
          context,
          FlashMessageType.success,
          'Acción completada',
          state.successMessage!,
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
                  productId: state.productId,
                  productName: state.productName,
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchOrders(state),
                        decoration: InputDecoration(
                          hintText: 'Buscar orden o mesa',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Buscar',
                                onPressed: () => _searchOrders(state),
                                icon: const Icon(Icons.search_rounded),
                              ),
                              IconButton(
                                tooltip: 'Limpiar búsqueda',
                                onPressed: () =>
                                    _searchOrders(state, clear: true),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    XsFilterButton(
                      onPressed: () => _openFilters(state),
                    ),
                  ],
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
                        onTap: () => _loadAndShowOrderDetail(
                          context,
                          order,
                          state.products,
                        ),
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
  ),
  );
}

Future<void> _loadAndShowOrderDetail(
  BuildContext context,
  Order summary,
  List<Product> products,
) async {
  if (summary.id == null) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final result = await getIt<GetOrderByIdUseCase>()(summary.id!);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    result.fold(
      (_) => _showOrderFlash(
        context,
        FlashMessageType.error,
        'No se pudo cargar el detalle',
      ),
      (detail) => _showOrderDetail(context, detail, products),
    );
  } catch (_) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    _showOrderFlash(
      context,
      FlashMessageType.error,
      'No se pudo cargar el detalle',
    );
  }
}

class _OrderDateFilters extends StatelessWidget {
  const _OrderDateFilters({
    required this.selected,
    required this.fromDate,
    required this.toDate,
    required this.onSelected,
  });

  final OrderDateFilter selected;
  final DateTime? fromDate;
  final DateTime? toDate;
  final void Function(OrderDateFilter, DateTime?, DateTime?) onSelected;

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
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDateRange: fromDate != null && toDate != null
            ? DateTimeRange(start: fromDate!, end: toDate!)
            : null,
      );
      if (range == null || !context.mounted) return;
      from = DateUtils.dateOnly(range.start);
      to = DateUtils.dateOnly(range.end);
    }
    if (!context.mounted) return;
    onSelected(filter, from, to);
  }
}

class _OrderFiltersSheet extends StatefulWidget {
  const _OrderFiltersSheet({
    required this.state,
    required this.onApply,
    required this.onClear,
  });

  final OrderState state;
  final void Function(
    OrderDateFilter,
    DateTime?,
    DateTime?,
    String,
    ProductLookup?,
  ) onApply;
  final VoidCallback onClear;

  @override
  State<_OrderFiltersSheet> createState() => _OrderFiltersSheetState();
}

class _OrderFiltersSheetState extends State<_OrderFiltersSheet> {
  late OrderDateFilter _dateFilter;
  DateTime? _fromDate;
  DateTime? _toDate;
  late String _status;
  ProductLookup? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _dateFilter = widget.state.dateFilter;
    _fromDate = widget.state.fromDate;
    _toDate = widget.state.toDate;
    _status = widget.state.orderStatus;
    if (widget.state.productId != null) {
      _selectedProduct = ProductLookup(
        id: widget.state.productId!,
        name: widget.state.productName ?? 'Producto seleccionado',
        code: '',
        active: true,
        deleted: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrar órdenes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Elige los filtros y aplícalos cuando estés listo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text('Periodo', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _OrderDateFilters(
            selected: _dateFilter,
            fromDate: _fromDate,
            toDate: _toDate,
            onSelected: (filter, fromDate, toDate) => setState(() {
              _dateFilter = filter;
              _fromDate = fromDate;
              _toDate = toDate;
            }),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _status,
            isExpanded: true,
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
          const SizedBox(height: 16),
          XsAsyncLookupField<ProductLookup>(
            selected: _selectedProduct,
            labelText: 'Producto',
            hintText: 'Escribe al menos 2 letras',
            search: getIt<ProductLookupService>().search,
            itemLabel: (product) {
              final label = product.code.isEmpty
                  ? product.name
                  : '${product.name} (${product.code})';
              if (product.deleted) return '$label · Eliminado';
              return '$label${product.active ? '' : ' · Inactivo'}';
            },
            onSelected: (product) => setState(() => _selectedProduct = product),
            onCleared: () => setState(() => _selectedProduct = null),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onClear,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => widget.onApply(
                    _dateFilter,
                    _fromDate,
                    _toDate,
                    _status,
                    _selectedProduct,
                  ),
                  icon: const Icon(Icons.filter_alt_rounded),
                  label: const Text('Filtrar'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _statusColor(order.status);
    final isDark = theme.brightness == Brightness.dark;
    final items = order.activeItemCount ??
        order.items.map((item) => item.productId).toSet().length;
    final units = order.activeUnitCount;
    final progress = order.status == 'CANCELLED'
        ? '${(order.cancelledItemCount ?? 0) > 0 ? order.cancelledItemCount : items} cancel.'
        : [
            if ((order.pendingItemCount ?? 0) > 0) '${order.pendingItemCount} pend.',
            if ((order.preparingItemCount ?? 0) > 0) '${order.preparingItemCount} prep.',
            if ((order.readyItemCount ?? 0) > 0) '${order.readyItemCount} listas',
            if ((order.servedItemCount ?? 0) > 0) '${order.servedItemCount} serv.',
            if ((order.cancelledItemCount ?? 0) > 0) '${order.cancelledItemCount} cancel.',
          ].join(' · ');
    return Material(
      color: isDark ? scheme.surfaceContainerLow : scheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: .08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? scheme.outlineVariant.withValues(alpha: .32)
                  : scheme.outlineVariant.withValues(alpha: .54),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: .045),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(_typeIcon(order.orderType), color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.25,
                      ),
                    ),
                  ),
                  _StatusChip(status: order.status ?? 'PENDING'),
                ],
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? .15 : .07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(_typeIcon(order.orderType), size: 16, color: AppColors.primary),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${_typeLabel(order.orderType)}${order.tableNumber?.isNotEmpty == true ? ' · ${order.tableNumber}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 15, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      order.createdAt == null
                          ? 'Fecha no disponible'
                          : DateFormat('dd/MM · HH:mm').format(order.createdAt!),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (order.hasNotes) Icon(Icons.sticky_note_2_outlined, size: 18, color: color),
                ],
              ),
              if (order.createdByName?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 5),
                Row(children: [
                  Icon(Icons.person_outline_rounded, size: 15, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Expanded(child: Text('Creada por ${order.createdByName}', style: theme.textTheme.bodySmall)),
                ]),
              ],
              if (progress.isNotEmpty) ...[
                const SizedBox(height: 11),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? .16 : .09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Icon(Icons.timelapse_rounded, size: 16, color: color),
                    const SizedBox(width: 7),
                    Text(progress, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.surfaceContainerHighest.withValues(alpha: .45)
                      : scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                children: [
                  Text(
                    '$items producto(s)${units == null ? '' : ' · ${units % 1 == 0 ? units.toInt() : units} und.'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'S/ ${order.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                ),
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
  Order detailOrder = order;
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
        builder: (_, controller) => SafeArea(
        top: false,
        child: StatefulBuilder(
        builder: (_, setSheetState) => BlocBuilder<OrderBloc, OrderState>(
        builder: (_, state) {
          Order currentOrder = detailOrder;
          for (final candidate in state.orders) {
            if (candidate.id == order.id && candidate.items.isNotEmpty) {
              currentOrder = candidate;
              break;
            }
          }
          if (state.savedOrder?.id == order.id) {
            currentOrder = state.savedOrder!;
          }
          final visibleItems = currentOrder.items
              .where((item) => item.status != 'CANCELLED')
              .toList()
            ..sort((first, second) =>
                (first.id ?? (1 << 62)).compareTo(second.id ?? (1 << 62)));
          final canStructurallyEdit = currentOrder.status == 'PENDING' &&
              visibleItems.isNotEmpty &&
              visibleItems.every((item) => item.status == 'PENDING');
          final selectableIds = currentOrder.items
              .where((item) =>
                  item.id != null &&
                  item.status != 'CANCELLED' &&
                  item.status != 'SERVED' &&
                  !currentOrder.incidentLockedItemIds.contains(item.id))
              .map((item) => item.id!)
              .toSet();
          quickServeSelected.removeWhere((id) => !selectableIds.contains(id));
          final selectedItems = currentOrder.items
              .where((item) => item.id != null && quickServeSelected.contains(item.id))
              .toList();
          final selectedState = selectedItems.isEmpty
              ? null
              : selectedItems.first.status;
          final selectedShareState = selectedItems.length > 1 &&
              selectedItems.every((item) => item.status == selectedState);
          final nextBulkStatus = selectedShareState && selectedState != null
              ? _nextItemStatus(selectedState)
              : null;
          final canServeDirectly =
              currentOrder.status != 'CANCELLED' &&
              currentOrder.status != 'COMPLETED' &&
              currentOrder.id != null &&
              getIt<AccessControl>().allows(AppCapability.editOrders) &&
              getIt<AccessControl>().allows(AppCapability.serveOrderItem);
          final canAdvanceSelected =
              currentOrder.status != 'CANCELLED' &&
              currentOrder.status != 'COMPLETED' &&
              currentOrder.id != null &&
              getIt<AccessControl>().allows(AppCapability.editOrders) &&
              nextBulkStatus != null &&
              !(nextBulkStatus == 'SERVED' && canServeDirectly);
          return ListView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.paddingOf(sheetContext).bottom,
        ),
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
          Row(
            children: [
              Icon(
                _typeIcon(currentOrder.orderType),
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(_typeLabel(currentOrder.orderType)),
            ],
          ),
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
                  if (currentOrder.id != null &&
                      item.id != null &&
                      getIt<AccessControl>().allows(
                        AppCapability.viewOrderItemHistory,
                      ))
                    _OrderItemHistorySection(
                      orderId: currentOrder.id!,
                      itemId: item.id!,
                    ),
                  const _DashedItemDivider(),
                ],
              ),
            ),
          ],
          if (currentOrder.status != 'CANCELLED')
            ...visibleItems.map(
            (item) {
              final isNoCharge = state.incidentsOrderId == currentOrder.id &&
                  _isNoChargeIncidentForItem(state.incidents, item.id);
              final appliedDiscount = state.incidentsOrderId == currentOrder.id
                  ? _approvedDiscountForItem(state.incidents, item.id)
                  : 0.0;
              final isIncidentLocked = currentOrder.incidentLockedItemIds.contains(item.id);
              final canSelectForQuickServe =
                  getIt<AccessControl>().allows(AppCapability.editOrders) &&
                  !isIncidentLocked &&
                  currentOrder.status != 'COMPLETED' &&
                  currentOrder.id != null &&
                  item.id != null &&
                  item.status != 'SERVED';
              final canCancelItem =
                  getIt<AccessControl>().allows(AppCapability.editOrders) &&
                  !isIncidentLocked &&
                  currentOrder.status != 'COMPLETED' &&
                  currentOrder.status != 'CANCELLED' &&
                  item.status != 'CANCELLED' &&
                  currentOrder.id != null &&
                  item.id != null &&
                  getIt<AccessControl>().allows(AppCapability.cancelOrderItem);
              final canEditPendingItem =
                  getIt<AccessControl>().allows(AppCapability.editOrders) &&
                  !isIncidentLocked &&
                  item.status == 'PENDING' &&
                  currentOrder.id != null &&
                  item.id != null &&
                  getIt<AccessControl>().allows(
                    AppCapability.editPendingOrderItem,
                  );
              final availableQuantity = _availableStock(products, item.productId);
              final maximumEditableQuantity = availableQuantity < 0
                  ? item.quantity.toInt()
                  : availableQuantity + item.quantity.toInt();
              return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  minVerticalPadding: 2,
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
                    _typeIcon(item.fulfillmentType),
                    size: 18,
                    color: switch (item.fulfillmentType) {
                      'TAKEAWAY' => Colors.deepOrange.shade700,
                      'DELIVERY' => Colors.teal.shade700,
                      _ => Colors.indigo.shade700,
                    },
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_productName(products, item.productId))),
                  Text(
                    'S/ ${item.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isNoCharge
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                      decoration: isNoCharge ? TextDecoration.lineThrough : null,
                    ),
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
                  if (canEditPendingItem)
                    IconButton(
                      tooltip: 'Editar cantidad y nota',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      onPressed: () => _showEditPendingOrderItemDialog(
                        context,
                        currentOrder.id!,
                        item,
                        maximumEditableQuantity,
                        _productById(products, item.productId),
                        onSaved: (updatedOrder) => setSheetState(() {
                          detailOrder = updatedOrder;
                        }),
                      ),
                    ),
                  if (canCancelItem)
                    IconButton(
                      tooltip: 'Cancelar producto',
                      visualDensity: VisualDensity.compact,
                      color: Colors.red.shade700,
                      icon: const Icon(Icons.cancel_outlined, size: 19),
                      onPressed: () => _showCancelOrderItemDialog(
                        context,
                        currentOrder.id!,
                        item.id!,
                        (updatedOrder) => setSheetState(() {
                          detailOrder = updatedOrder;
                        }),
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
                          if (isNoCharge)
                            const _NoChargeIncidentBadge(),
                          if (appliedDiscount > 0)
                            _DiscountIncidentBadge(amount: appliedDiscount),
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
                            isIncidentLocked: isIncidentLocked,
                            onSaved: (updatedOrder) => setSheetState(() {
                              detailOrder = updatedOrder;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentOrder.id != null &&
                    item.id != null &&
                    getIt<AccessControl>().allows(
                      AppCapability.viewOrderItemHistory,
                    ))
                  _OrderItemHistorySection(
                    orderId: currentOrder.id!,
                    itemId: item.id!,
                  ),
                const _DashedItemDivider(),
              ],
            );
            },
          ),
          if (canServeDirectly && selectableIds.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setSheetState(() => quickServeSelected
                  ..clear()
                  ..addAll(selectableIds)),
                icon: const Icon(Icons.select_all_rounded),
                label: const Text('Seleccionar todos'),
              ),
            ),
          if (canServeDirectly && selectableIds.isNotEmpty) ...[
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
                      final completer = Completer<Order>();
                      context.read<OrderBloc>().add(ChangeOrderItemsStatus(
                            currentOrder.id!,
                            itemIds,
                            'SERVE_DIRECTLY',
                            comment: 'Productos servidos directamente en lote',
                            completer: completer,
                          ));
                      try {
                        final updatedOrder = await completer.future;
                        if (sheetContext.mounted) {
                          setSheetState(() => detailOrder = updatedOrder);
                        }
                      } catch (_) {
                        if (sheetContext.mounted) {
                          _showOrderFlash(
                            context,
                            FlashMessageType.error,
                            'No se pudo registrar la entrega',
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.done_all_outlined),
              label: Text(
                quickServeSelected.isEmpty
                    ? 'Marque productos entregados'
                    : 'Registrar entrega (${quickServeSelected.length})',
              ),
            ),
          ],
          if (canAdvanceSelected) ...[
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () async {
                final itemIds = quickServeSelected.toList();
                final completer = Completer<Order>();
                context.read<OrderBloc>().add(ChangeOrderItemsStatus(
                      currentOrder.id!,
                      itemIds,
                      nextBulkStatus!,
                      comment: 'Avance de estado en lote',
                      completer: completer,
                    ));
                try {
                  final updatedOrder = await completer.future;
                  if (sheetContext.mounted) {
                    setSheetState(() {
                      detailOrder = updatedOrder;
                      quickServeSelected.clear();
                    });
                  }
                } catch (_) {
                  if (sheetContext.mounted) {
                    _showOrderFlash(
                      context,
                      FlashMessageType.error,
                      'No se pudieron actualizar los productos',
                    );
                  }
                }
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                'Pasar ${quickServeSelected.length} a ${_itemStatusLabel(nextBulkStatus!)}',
              ),
            ),
          ],
          if (currentOrder.status != 'CANCELLED' &&
              currentOrder.status != 'COMPLETED' &&
              currentOrder.id != null &&
              currentOrder.items.any((item) =>
                  item.status != 'CANCELLED' &&
                  !currentOrder.incidentLockedItemIds.contains(item.id)) &&
              getIt<AccessControl>().allows(AppCapability.editOrders) &&
              getIt<AccessControl>().allows(
                AppCapability.correctOrderItemStatus,
              ))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _showBulkStatusDialog(
                      context,
                      currentOrder,
                      products,
                      onSaved: (updatedOrder) => setSheetState(() {
                        detailOrder = updatedOrder;
                      }),
                    ),
                icon: const Icon(Icons.done_all_outlined),
                label: const Text('Corregir estados'),
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
          if (canStructurallyEdit &&
              getIt<AccessControl>().allows(AppCapability.editOrders)) ...[
              FilledButton.icon(
                onPressed: () async {
                  final updatedOrder = await _openOrderForm(context, order: currentOrder);
                  final sheetNavigator = Navigator.of(sheetContext);
                  if (updatedOrder != null && sheetNavigator.mounted) {
                    sheetNavigator.pop();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar orden'),
              ),
              const SizedBox(height: 10),
            ],
          if (_canEditActiveOrder(currentOrder.status) &&
              !canStructurallyEdit &&
              getIt<AccessControl>().allows(AppCapability.editOrders) &&
              getIt<AccessControl>().allows(AppCapability.addOrderItem)) ...[
              FilledButton.tonalIcon(
                onPressed: () async {
                  final updatedOrder = await _openOrderForm(
                    context,
                    order: currentOrder,
                    appendItemsOnly: true,
                  );
                  if (updatedOrder != null && sheetContext.mounted) {
                    setSheetState(() => detailOrder = updatedOrder);
                  }
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Agregar productos'),
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
              getIt<AccessControl>().allows(AppCapability.cancelOrders)) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _confirmCancel(
                context,
                currentOrder,
                onSaved: (updatedOrder) => setSheetState(() {
                  detailOrder = updatedOrder;
                }),
              ),
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
  {required void Function(Order order) onSaved}
) async {
  final bloc = context.read<OrderBloc>();
  final selected = <int>{};
  final commentController = TextEditingController();
  var targetStatus = 'RESTORE_PREVIOUS';
  final access = getIt<AccessControl>();
  if (!access.allows(AppCapability.editOrders) ||
      !access.allows(AppCapability.correctOrderItemStatus)) {
    return;
  }
  final availableStatuses = <String>{
    'RESTORE_PREVIOUS',
    'CORRECT_TO_PENDING',
    'CORRECT_TO_PREPARING',
    'CORRECT_TO_READY',
    'CORRECT_TO_SERVED',
  };
  if (availableStatuses.isEmpty || order.id == null) return;

  List<OrderItem> eligibleItems() => order.items.where((item) {
        if (item.id == null ||
            item.status == 'CANCELLED' ||
            order.incidentLockedItemIds.contains(item.id)) return false;
        return switch (targetStatus) {
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
  final updatedOrder = await showDialog<Order>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: bloc,
      child: StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: const Text('Corregir estados de productos'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text('Elija una corrección y marque los productos compatibles.'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                    value: targetStatus,
                    decoration: const InputDecoration(labelText: 'Corrección a aplicar'),
                    items: [
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem<String>(
                          enabled: false,
                          child: Text('— Estados directos —'),
                        ),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'RESTORE_PREVIOUS', child: Text('Restaurar estado anterior')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_PENDING', child: Text('Estado directo: Pendiente')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_PREPARING', child: Text('Estado directo: En preparación')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_READY', child: Text('Estado directo: Listo')),
                      if (access.allows(AppCapability.correctOrderItemStatus))
                        const DropdownMenuItem(value: 'CORRECT_TO_SERVED', child: Text('Estado directo: Servido')),
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
                      'Acción de estado directo: no modifica stock ni importes.',
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
                        labelText: 'Comentario (opcional)',
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton.icon(
              onPressed: selected.isEmpty ? null : () async {
                final completer = Completer<Order>();
                bloc.add(ChangeOrderItemsStatus(
                  order.id!,
                  selected.toList(),
                  targetStatus,
                  comment: commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                  completer: completer,
                ));
                try {
                  final savedOrder = await completer.future;
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, savedOrder);
                  }
                } catch (_) {
                  if (dialogContext.mounted) {
                    _showOrderFlash(
                      dialogContext,
                      FlashMessageType.error,
                      'No se pudieron actualizar los productos',
                    );
                  }
                }
              },
              icon: const Icon(Icons.done_all_outlined),
              label: Text('Aplicar a ${selected.length}'),
            ),
          ],
        ),
      ),
    ),
  );
  if (updatedOrder != null && context.mounted) onSaved(updatedOrder);
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

void _confirmCancel(
  BuildContext context,
  Order order, {
  required void Function(Order order) onSaved,
}) {
  if (!getIt<AccessControl>().allows(AppCapability.cancelOrders)) return;
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
          onPressed: () async {
            Navigator.pop(dialogContext);
            final completer = Completer<Order>();
            context.read<OrderBloc>().add(ChangeOrderStatus(
              order.id!,
              'CANCELLED',
              completer: completer,
            ));
            try {
              onSaved(await completer.future);
            } catch (_) {
              // El BLoC muestra el toast de error correspondiente.
            }
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Sí, cancelar'),
        ),
      ],
    ),
  );
}

Future<Order?> _openOrderForm(
  BuildContext context, {
  Order? order,
  bool appendItemsOnly = false,
}) async {
  final required = appendItemsOnly
      ? AppCapability.addOrderItem
      : order == null
      ? AppCapability.createOrders
      : AppCapability.editOrders;
  await getIt<PermissionSyncService>().refresh(force: true);
  if (!context.mounted) return null;
  if (!getIt<AccessControl>().allows(required)) {
    _showOrderFlash(
      context,
      FlashMessageType.warning,
      'Acción no autorizada',
      'Ya no cuentas con permiso para realizar esta acción.',
    );
    return null;
  }
  final bloc = context.read<OrderBloc>();
  final navigator = Navigator.of(context, rootNavigator: true);
  final completer = Completer<List<Product>>();
  // El compositor solo debe reaccionar al resultado de su propio guardado,
  // no a una mutacion anterior que aun permanezca en el estado compartido.
  bloc.add(const ClearOrderAction());
  bloc.add(RefreshOrderProducts(completer));

  try {
    // No reutilizar la lista recibida: puede haber sido reservada por otro
    // usuario mientras esta pantalla permanecía abierta.
    final freshProducts = await completer.future;
    if (!navigator.mounted) return null;

    return await navigator.push<Order>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: OrderComposerPage(
            order: order,
            appendItemsOnly: appendItemsOnly,
            initialProducts: freshProducts,
          ),
        ),
      ),
    );
  } catch (_) {
    if (navigator.mounted) {
      _showOrderFlash(
        context,
        FlashMessageType.error,
        'No se pudo actualizar la disponibilidad',
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
              categories: state.productCategories,
              selectedCategoryIds: state.selectedProductCategoryIds,
              availableOnly: state.availableProductsOnly,
              searchQuery: state.productSearchQuery,
              hasMore: state.hasMoreProducts,
              isLoadingMore: state.isLoadingMoreProducts,
              onLoadMore: () => sheetContext.read<OrderBloc>().add(
                const LoadMoreOrderProducts(),
              ),
              onSearchChanged: (query) => sheetContext.read<OrderBloc>().add(
                SearchOrderProducts(query),
              ),
              onFiltersChanged: (categoryIds, availableOnly) =>
                  sheetContext.read<OrderBloc>().add(
                    FilterOrderProducts(
                      categoryIds: categoryIds,
                      availableOnly: availableOnly,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
    if (selected == null) return;
    if (selected.availableStock == 0) {
      _showOrderFlash(
        context,
        FlashMessageType.warning,
        'Sin stock disponible',
        'El producto no tiene stock disponible.',
      );
      return;
    }
    final index = items.indexWhere((item) => item.productId == selected.id);
    final maximumQuantity = _maximumQuantityForProduct(selected.id);
    if (index >= 0 && items[index].quantity + 1 > maximumQuantity) {
      _showOrderFlash(
        context,
        FlashMessageType.warning,
        'Stock insuficiente',
        'Solo hay $maximumQuantity unidad(es) disponible(s).',
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
      _showOrderFlash(
        context,
        FlashMessageType.warning,
        'Agregue productos',
        'La orden debe incluir al menos un producto.',
      );
      return;
    }
    for (final item in items) {
      final availableStock = _maximumQuantityForProduct(item.productId);
      if (availableStock < 0 || item.quantity > availableStock) {
        _showOrderFlash(
          context,
          FlashMessageType.warning,
          'Stock insuficiente',
          'La cantidad de ${_productName(availableProducts, item.productId)} supera el stock disponible.',
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
IconData _typeIcon(String type) => switch (type) {
  'DINE_IN' => Icons.table_restaurant_outlined,
  'TAKEAWAY' => Icons.shopping_bag_outlined,
  'DELIVERY' => Icons.delivery_dining_outlined,
  _ => Icons.receipt_long_outlined,
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

bool _isNoChargeIncidentForItem(List<OrderItemIncident> incidents, int? itemId) =>
    itemId != null &&
    incidents.any((incident) =>
        incident.orderItemId == itemId &&
        incident.resolution == 'CANCEL_NO_CHARGE' &&
        _isApprovedIncident(incident.status));

double _approvedDiscountForItem(
  List<OrderItemIncident> incidents,
  int? itemId,
) => itemId == null
    ? 0
    : incidents
        .where((incident) =>
            incident.orderItemId == itemId &&
            incident.resolution == 'DISCOUNT' &&
            _isApprovedIncident(incident.status))
        .fold(0.0, (total, incident) => total + incident.discountAmount);

bool _isApprovedIncident(String status) {
  final normalized = status.trim().toUpperCase();
  return normalized == 'APPROVED' || normalized == 'APROVED';
}

class _NoChargeIncidentBadge extends StatelessWidget {
  const _NoChargeIncidentBadge();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.money_off_csred_rounded, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            'Servido · no cobrado',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DiscountIncidentBadge extends StatelessWidget {
  const _DiscountIncidentBadge({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Descuento -S/ ${amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _OrderItemHistorySection extends StatefulWidget {
  const _OrderItemHistorySection({required this.orderId, required this.itemId});

  final int orderId;
  final int itemId;

  @override
  State<_OrderItemHistorySection> createState() => _OrderItemHistorySectionState();
}

class _OrderItemHistorySectionState extends State<_OrderItemHistorySection> {
  Future<List<OrderItemStatusHistory>>? _history;
  var _expanded = false;

  void _toggle() {
    final willExpand = !_expanded;
    setState(() {
      _expanded = willExpand;
      // El historial puede cambiar mientras el detalle permanece abierto.
      // Cada vez que el usuario lo despliega se consulta nuevamente.
      if (willExpand) {
        _history = _loadHistory();
      }
    });
  }

  Future<List<OrderItemStatusHistory>> _loadHistory() async {
    final result = await getIt<GetOrderItemStatusHistoryUseCase>()(
      widget.orderId,
      widget.itemId,
    );
    return result.fold((failure) => throw StateError(failure.message), (value) => value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 1, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
            onPressed: _toggle,
            tooltip: _expanded ? 'Ocultar historial' : 'Ver historial de estados',
            icon: Icon(_expanded ? Icons.expand_less_rounded : Icons.history_rounded, size: 19),
            color: colorScheme.onSurfaceVariant,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(5),
              minimumSize: const Size(32, 32),
            ),
          ),
          ),
          if (_expanded)
            FutureBuilder<List<OrderItemStatusHistory>>(
              future: _history,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text('No se pudo cargar el historial.', style: TextStyle(color: colorScheme.error)),
                  );
                }
                final history = snapshot.data ?? const [];
                if (history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text('Aún no hay cambios de estado registrados.'),
                  );
                }
                return Container(
                  margin: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: history.map((entry) => _StatusHistoryEntry(entry: entry)).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatusHistoryEntry extends StatelessWidget {
  const _StatusHistoryEntry({required this.entry});

  final OrderItemStatusHistory entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = entry.changedAt == null
        ? 'Fecha no disponible'
        : DateFormat('dd/MM · HH:mm').format(entry.changedAt!);
    final transition = entry.previousStatus == null
        ? _itemStatusLabel(entry.newStatus)
        : '${_itemStatusLabel(entry.previousStatus!)} → ${_itemStatusLabel(entry.newStatus)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 10, color: _itemStatusColor(entry.newStatus)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transition, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '$date · ${entry.changedByName?.trim().isNotEmpty == true ? entry.changedByName!.trim() : 'Usuario #${entry.changedBy ?? '—'}'}',
                  style: theme.textTheme.bodySmall,
                ),
                if (entry.comment?.trim().isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(entry.comment!.trim(), style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
