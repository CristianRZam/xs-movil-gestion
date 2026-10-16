import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/domain/usecases/order_usecases.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_bloc.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_event.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_state.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KitchenQueueScreen extends StatelessWidget {
  const KitchenQueueScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => OrderBloc(
          getIt<GetOrdersUseCase>(),
          getIt<GetKitchenQueueUseCase>(),
          getIt<CreateOrderUseCase>(),
          getIt<UpdateOrderUseCase>(),
          getIt<UpdateOrderStatusUseCase>(),
          getIt<AddOrderItemUseCase>(),
          getIt<AddOrderItemsUseCase>(),
          getIt<UpdatePendingOrderItemUseCase>(),
          getIt<UpdateOrderItemStatusUseCase>(),
          getIt<UpdateOrderItemsStatusUseCase>(),
          getIt<CancelPendingOrderItemUseCase>(),
          getIt<ReportOrderItemIncidentUseCase>(),
          getIt<GetOrderIncidentsUseCase>(),
          getIt<DeleteOrderUseCase>(),
          getIt<GetProductViewUseCase>(),
          getIt<ExistsOpenCashSessionUseCase>(),
        )..add(const LoadKitchenQueue()),
        child: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.status == OrderStatus.failure) {
              FlashMessage.show(
                context,
                type: FlashMessageType.error,
                title: 'No se pudo actualizar la cocina',
                message: state.errorMessage!,
              );
              context.read<OrderBloc>().add(const ClearOrderError());
            }
            if (state.savedOrder != null) {
              context.read<OrderBloc>().add(const ClearOrderAction());
              context.read<OrderBloc>().add(const LoadKitchenQueue());
            }
          },
          builder: (context, state) => LoadingOverlay(
            isLoading: state.status == OrderStatus.loading,
            child: Scaffold(
              appBar: const XsAppBar(title: 'Cocina', backIcon: false),
              endDrawer: const XsDrawer(),
              body: _KitchenWorkflowBoard(orders: state.kitchenOrders),
            ),
          ),
        ),
      );
}

enum _KitchenStage { pending, preparing, ready }

class _KitchenWorkflowBoard extends StatefulWidget {
  const _KitchenWorkflowBoard({required this.orders});

  final List<Order> orders;

  @override
  State<_KitchenWorkflowBoard> createState() => _KitchenWorkflowBoardState();
}

class _KitchenWorkflowBoardState extends State<_KitchenWorkflowBoard> {
  _KitchenStage _stage = _KitchenStage.pending;

  @override
  Widget build(BuildContext context) {
    final status = switch (_stage) {
      _KitchenStage.pending => 'PENDING',
      _KitchenStage.preparing => 'PREPARING',
      _KitchenStage.ready => 'READY',
    };
    final orders = widget.orders
        .where((order) => order.items.any((item) => item.status == status))
        .toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          color: colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SegmentedButton<_KitchenStage>(
              segments: const [
                ButtonSegment(
                  value: _KitchenStage.pending,
                  icon: Icon(Icons.receipt_long_outlined, size: 18),
                  label: Text('Pendientes', softWrap: false),
                ),
                ButtonSegment(
                  value: _KitchenStage.preparing,
                  icon: Icon(Icons.soup_kitchen_outlined, size: 18),
                  label: Text('Preparando', softWrap: false),
                ),
                ButtonSegment(
                  value: _KitchenStage.ready,
                  icon: Icon(Icons.room_service_outlined, size: 18),
                  label: Text('Entrega', softWrap: false),
                ),
              ],
              selected: {_stage},
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              onSelectionChanged: (selection) =>
                  setState(() => _stage = selection.first),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                context.read<OrderBloc>().add(const LoadKitchenQueue()),
            child: orders.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(28),
                    children: [
                      const SizedBox(height: 90),
                      Icon(
                        _stage == _KitchenStage.ready
                            ? Icons.task_alt_outlined
                            : Icons.restaurant_menu_rounded,
                        size: 58,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          switch (_stage) {
                            _KitchenStage.pending => 'No hay productos pendientes.',
                            _KitchenStage.preparing => 'No hay productos en preparación.',
                            _KitchenStage.ready => 'No hay productos listos para entregar.',
                          },
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _KitchenStageOrderCard(
                      order: orders[index],
                      status: status,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _KitchenStageOrderCard extends StatelessWidget {
  const _KitchenStageOrderCard({required this.order, required this.status});

  final Order order;
  final String status;

  @override
  Widget build(BuildContext context) {
    final items = order.items.where((item) => item.status == status).toList();
    final nextStatus = switch (status) {
      'PENDING' => 'PREPARING',
      'PREPARING' => 'READY',
      'READY' => 'SERVED',
      _ => null,
    };
    final capability = nextStatus == 'PREPARING'
        ? AppCapability.prepareOrderItem
        : nextStatus == 'READY'
        ? AppCapability.markOrderItemReady
        : nextStatus == 'SERVED'
        ? AppCapability.serveOrderItem
        : null;
    final canAdvance = nextStatus != null &&
        capability != null &&
        order.id != null &&
        getIt<AccessControl>().allows(capability);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _KitchenStatusChip(status: status),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              order.tableNumber?.trim().isNotEmpty == true
                  ? 'Mesa ${order.tableNumber}'
                  : _fulfillmentLabel(order.orderType),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 22),
            ...items.map(
              (item) => _KitchenStageItem(
                order: order,
                item: item,
                nextStatus: nextStatus,
                canAdvance: canAdvance,
              ),
            ),
            if (canAdvance && items.length > 1) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => context.read<OrderBloc>().add(
                        ChangeOrderItemsStatus(
                          order.id!,
                          items.map((item) => item.id!).toList(),
                          nextStatus!,
                          fromKitchen: true,
                        ),
                      ),
                  icon: const Icon(Icons.done_all_outlined),
                  label: Text(
                    nextStatus == 'PREPARING'
                        ? 'Iniciar ${items.length} productos'
                        : nextStatus == 'READY'
                        ? 'Marcar ${items.length} como listos'
                        : 'Entregar ${items.length} productos',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KitchenStageItem extends StatelessWidget {
  const _KitchenStageItem({
    required this.order,
    required this.item,
    required this.nextStatus,
    required this.canAdvance,
  });

  final Order order;
  final OrderItem item;
  final String? nextStatus;
  final bool canAdvance;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              child: Text(_quantity(item.quantity)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName?.trim().isNotEmpty == true
                        ? item.productName!
                        : 'Producto #${item.productId}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _fulfillmentLabel(item.fulfillmentType),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (item.notes?.trim().isNotEmpty == true)
                    Text(
                      item.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (canAdvance)
              FilledButton(
                onPressed: () => context.read<OrderBloc>().add(
                      ChangeOrderItemStatus(
                        order.id!,
                        item.id!,
                        nextStatus!,
                        fromKitchen: true,
                      ),
                    ),
                child: Text(
                  nextStatus == 'PREPARING'
                      ? 'Preparar'
                      : nextStatus == 'READY'
                      ? 'Listo'
                      : 'Entregar',
                ),
              ),
          ],
        ),
      );
}

class _KitchenOrderCard extends StatelessWidget {
  const _KitchenOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final pendingItems = order.items.where((item) => item.status != 'SERVED' && item.status != 'CANCELLED').toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 8),
                Expanded(child: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                Text(order.tableNumber?.isNotEmpty == true ? 'Mesa ${order.tableNumber}' : _fulfillmentLabel(order.orderType)),
              ],
            ),
            const Divider(height: 24),
            ...pendingItems.map((item) => _KitchenItemAction(order: order, item: item)),
          ],
        ),
      ),
    );
  }
}

class _KitchenItemAction extends StatelessWidget {
  const _KitchenItemAction({required this.order, required this.item});
  final Order order;
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final nextStatus = switch (item.status) {
      'PENDING' => 'PREPARING',
      'PREPARING' => 'READY',
      _ => null,
    };
    final capability = nextStatus == 'PREPARING'
        ? AppCapability.prepareOrderItem
        : nextStatus == 'READY'
            ? AppCapability.markOrderItemReady
            : null;
    final canChange = nextStatus != null && capability != null &&
        getIt<AccessControl>().allows(capability) && order.id != null && item.id != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName?.trim().isNotEmpty == true
                      ? item.productName!
                      : 'Producto #${item.productId}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('${_quantity(item.quantity)} u. · ${_fulfillmentLabel(item.fulfillmentType)} · ${_statusLabel(item.status)}'),
                if (item.notes?.isNotEmpty == true)
                  Text(item.notes!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (canChange)
            FilledButton.tonal(
              onPressed: () => context.read<OrderBloc>().add(
                    ChangeOrderItemStatus(
                      order.id!,
                      item.id!,
                      nextStatus,
                      fromKitchen: true,
                    ),
                  ),
              child: Text(nextStatus == 'PREPARING' ? 'Preparar' : 'Listo'),
            )
          else
            _KitchenStatusChip(status: item.status),
        ],
      ),
    );
  }
}

class _KitchenStatusChip extends StatelessWidget {
  const _KitchenStatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) => Chip(
        label: Text(_statusLabel(status)),
        visualDensity: VisualDensity.compact,
      );
}

String _fulfillmentLabel(String type) => switch (type) {
      'DINE_IN' => 'En local',
      'TAKEAWAY' => 'Para llevar',
      'DELIVERY' => 'Entrega',
      _ => type,
    };

String _statusLabel(String status) => switch (status) {
      'PENDING' => 'Pendiente',
      'PREPARING' => 'Preparando',
      'READY' => 'Listo',
      'SERVED' => 'Servido',
      'CANCELLED' => 'Cancelado',
      _ => status,
    };

String _quantity(double quantity) => quantity % 1 == 0
    ? quantity.toInt().toString()
    : quantity.toString();
