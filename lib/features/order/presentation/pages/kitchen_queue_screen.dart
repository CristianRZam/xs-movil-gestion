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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
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
              body: RefreshIndicator(
                onRefresh: () async => context.read<OrderBloc>().add(const LoadKitchenQueue()),
                child: state.kitchenOrders.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(28),
                        children: const [
                          SizedBox(height: 90),
                          Icon(Icons.restaurant_menu_rounded, size: 58),
                          SizedBox(height: 14),
                          Center(child: Text('No hay productos pendientes de cocina.')),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.kitchenOrders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) => _KitchenOrderCard(order: state.kitchenOrders[index]),
                      ),
              ),
            ),
          ),
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
                    ChangeOrderItemStatus(order.id!, item.id!, nextStatus),
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
