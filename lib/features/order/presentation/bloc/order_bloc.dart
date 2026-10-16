import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
import 'package:app_movil_sistema/features/order/domain/usecases/order_usecases.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrdersUseCase;
  final GetKitchenQueueUseCase getKitchenQueueUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final UpdateOrderUseCase updateOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final AddOrderItemUseCase addOrderItemUseCase;
  final AddOrderItemsUseCase addOrderItemsUseCase;
  final UpdatePendingOrderItemUseCase updatePendingOrderItemUseCase;
  final SplitPendingOrderItemUseCase splitPendingOrderItemUseCase;
  final UpdateOrderItemStatusUseCase updateOrderItemStatusUseCase;
  final UpdateOrderItemsStatusUseCase updateOrderItemsStatusUseCase;
  final CancelPendingOrderItemUseCase cancelPendingOrderItemUseCase;
  final ReportOrderItemIncidentUseCase reportOrderItemIncidentUseCase;
  final GetOrderIncidentsUseCase getOrderIncidentsUseCase;
  final DeleteOrderUseCase deleteOrderUseCase;
  final GetProductViewUseCase getProductViewUseCase;
  final ExistsOpenCashSessionUseCase existsOpenCashSessionUseCase;

  OrderBloc(
    this.getOrdersUseCase,
    this.getKitchenQueueUseCase,
    this.createOrderUseCase,
    this.updateOrderUseCase,
    this.updateOrderStatusUseCase,
    this.addOrderItemUseCase,
    this.addOrderItemsUseCase,
    this.updatePendingOrderItemUseCase,
    this.splitPendingOrderItemUseCase,
    this.updateOrderItemStatusUseCase,
    this.updateOrderItemsStatusUseCase,
    this.cancelPendingOrderItemUseCase,
    this.reportOrderItemIncidentUseCase,
    this.getOrderIncidentsUseCase,
    this.deleteOrderUseCase,
    this.getProductViewUseCase,
    this.existsOpenCashSessionUseCase,
  ) : super(const OrderState()) {
    on<LoadOrders>(_loadOrders);
    on<LoadMoreOrders>(_loadMoreOrders);
    on<LoadKitchenQueue>(_loadKitchenQueue);
    on<LoadOrderProducts>(_loadProducts);
    on<LoadMoreOrderProducts>(_loadMoreProducts);
    on<SearchOrderProducts>(_searchProducts);
    on<FilterOrderProducts>(_filterProducts);
    on<RefreshOrderProducts>(_refreshProductsForForm);
    on<CheckOpenCashSession>(_checkOpenCashSession);
    on<SaveOrder>(_saveOrder);
    on<ChangeOrderStatus>(_changeStatus);
    on<AddOrderItem>(_addItem);
    on<AddOrderItems>(_addItems);
    on<UpdatePendingOrderItem>(_updatePendingItem);
    on<SplitPendingOrderItem>(_splitPendingItem);
    on<ChangeOrderItemStatus>(_changeItemStatus);
    on<ChangeOrderItemsStatus>(_changeItemsStatus);
    on<CancelPendingOrderItem>(_cancelPendingItem);
    on<ReportOrderItemIncident>(_reportIncident);
    on<LoadOrderIncidents>(_loadIncidents);
    on<DeleteOrder>(_deleteOrder);
    on<ClearOrderAction>(
      (_, emit) => emit(state.copyWith(savedOrder: null, deleted: null, successMessage: null)),
    );
    on<ClearOrderError>(
      (_, emit) =>
          emit(state.copyWith(status: OrderStatus.success, errorMessage: null)),
    );
  }

  Future<void> _loadKitchenQueue(
    LoadKitchenQueue event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await getKitchenQueueUseCase(
      size: EnvConfig.salesAndOrdersPageSize,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: OrderStatus.success,
          kitchenOrders: page.orders,
        ),
      ),
    );
  }

  Future<void> _addItem(AddOrderItem event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await addOrderItemUseCase(event.orderId, event.item);
    await result.fold(
      (failure) async => emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message)),
      (order) => _emitMutationSuccess(emit, savedOrder: order, successMessage: 'Producto agregado a la orden correctamente.'),
    );
  }

  Future<void> _addItems(AddOrderItems event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await addOrderItemsUseCase(event.orderId, event.items);
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(emit, savedOrder: order, successMessage: 'Productos agregados a la orden correctamente.');
      },
    );
  }

  Future<void> _updatePendingItem(
    UpdatePendingOrderItem event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await updatePendingOrderItemUseCase(
      event.orderId,
      event.itemId,
      event.item,
    );
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(
          status: OrderStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(emit, savedOrder: order, successMessage: 'Producto actualizado correctamente.');
      },
    );
  }

  Future<void> _splitPendingItem(
    SplitPendingOrderItem event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await splitPendingOrderItemUseCase(
      event.orderId,
      event.itemId,
      event.quantity,
      event.fulfillmentType,
    );
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(
          emit,
          savedOrder: order,
          successMessage: 'Producto dividido correctamente.',
        );
      },
    );
  }

  Future<void> _changeItemStatus(ChangeOrderItemStatus event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await updateOrderItemStatusUseCase(
      event.orderId,
      event.itemId,
      event.status,
      comment: event.comment,
      fromKitchen: event.fromKitchen,
    );
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(
          emit,
          savedOrder: order,
          successMessage: 'Estado del producto actualizado correctamente.',
        );
      },
    );
  }

  Future<void> _changeItemsStatus(ChangeOrderItemsStatus event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await updateOrderItemsStatusUseCase(
      event.orderId,
      event.itemIds,
      event.status,
      comment: event.comment,
      fromKitchen: event.fromKitchen,
    );
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(emit, savedOrder: order, successMessage: 'Estados de los productos actualizados correctamente.');
      },
    );
  }

  Future<void> _cancelPendingItem(CancelPendingOrderItem event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await cancelPendingOrderItemUseCase(event.orderId, event.itemId, comment: event.comment, stockDisposition: event.stockDisposition);
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(
          emit,
          savedOrder: order,
          successMessage: 'Producto cancelado correctamente.',
        );
      },
    );
  }

  Future<void> _reportIncident(ReportOrderItemIncident event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await reportOrderItemIncidentUseCase(event.orderId, event.itemId, event.resolution, event.reason, discountAmount: event.discountAmount);
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (order) async {
        await _emitMutationSuccess(emit, savedOrder: order, successMessage: 'Incidencia registrada correctamente.');
        final incidents = await getOrderIncidentsUseCase(event.orderId);
        incidents.fold(
          (_) {},
          (value) {
            final updatedOrder = _withIncidentDiscount(order, value);
            if (event.completer?.isCompleted == false) {
              event.completer!.complete(updatedOrder);
            }
            emit(state.copyWith(
              savedOrder: updatedOrder,
              incidents: value,
              incidentsOrderId: event.orderId,
              successMessage: null,
            ));
          },
        );
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
      },
    );
  }

  Future<void> _loadIncidents(LoadOrderIncidents event, Emitter<OrderState> emit) async {
    final result = await getOrderIncidentsUseCase(event.orderId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (incidents) {
        emit(state.copyWith(
          incidents: incidents,
          incidentsOrderId: event.orderId,
        ));
      },
    );
  }

  Future<void> _checkOpenCashSession(
    CheckOpenCashSession event,
    Emitter<OrderState> emit,
  ) async {
    final result = await existsOpenCashSessionUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(isCashSessionOpen: false, errorMessage: failure.message),
      ),
      (isOpen) => emit(state.copyWith(isCashSessionOpen: isOpen)),
    );
  }

  Future<void> _loadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await getOrdersUseCase(
      page: 0,
      size: EnvConfig.salesAndOrdersPageSize,
      from: event.fromDate,
      to: event.toDate,
      status: event.orderStatus,
      search: event.searchQuery,
      productId: event.productId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: OrderStatus.success,
          orders: page.orders,
          ordersPage: page.page,
          hasMoreOrders: page.hasMore,
          isLoadingMoreOrders: false,
          dateFilter: event.filter,
          fromDate: event.fromDate,
          toDate: event.toDate,
          orderStatus: event.orderStatus,
          searchQuery: event.searchQuery,
          productId: event.productId,
          productName: event.productName,
        ),
      ),
    );
  }

  Future<void> _loadMoreOrders(
    LoadMoreOrders event,
    Emitter<OrderState> emit,
  ) async {
    if (!state.hasMoreOrders || state.isLoadingMoreOrders) return;
    emit(state.copyWith(isLoadingMoreOrders: true));
    final result = await getOrdersUseCase(
      page: state.ordersPage + 1,
      size: EnvConfig.salesAndOrdersPageSize,
      from: state.fromDate,
      to: state.toDate,
      status: state.orderStatus,
      search: state.searchQuery,
      productId: state.productId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMoreOrders: false,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          orders: [...state.orders, ...page.orders],
          ordersPage: page.page,
          hasMoreOrders: page.hasMore,
          isLoadingMoreOrders: false,
        ),
      ),
    );
  }

  Future<void> _loadProducts(
    LoadOrderProducts event,
    Emitter<OrderState> emit,
  ) async {
    final result = await getProductViewUseCase(
      ProductViewRequest(
        page: 0,
        size: EnvConfig.productPageSize,
        status: true,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          products: response.products,
          productCategories: response.categories,
          totalProducts: response.totalProducts,
        ),
      ),
    );
  }

  Future<void> _loadMoreProducts(
    LoadMoreOrderProducts event,
    Emitter<OrderState> emit,
  ) async {
    if (!state.hasMoreProducts || state.isLoadingMoreProducts) return;
    emit(state.copyWith(isLoadingMoreProducts: true));
    final page = state.products.length ~/ EnvConfig.productPageSize;
    final result = await getProductViewUseCase(
      ProductViewRequest(
        page: page,
        size: EnvConfig.productPageSize,
        status: true,
        name: state.productSearchQuery.isEmpty
            ? null
            : state.productSearchQuery,
        categories: state.selectedProductCategoryIds,
        availableOnly: state.availableProductsOnly,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMoreProducts: false,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          products: [...state.products, ...response.products],
          productCategories: response.categories,
          totalProducts: response.totalProducts,
          isLoadingMoreProducts: false,
        ),
      ),
    );
  }

  Future<void> _searchProducts(
    SearchOrderProducts event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(productSearchQuery: event.query));
    final result = await getProductViewUseCase(
      ProductViewRequest(
        name: event.query.isEmpty ? null : event.query,
        page: 0,
        size: EnvConfig.productPageSize,
        status: true,
        categories: state.selectedProductCategoryIds,
        availableOnly: state.availableProductsOnly,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          products: response.products,
          productCategories: response.categories,
          totalProducts: response.totalProducts,
        ),
      ),
    );
  }

  Future<void> _filterProducts(
    FilterOrderProducts event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      selectedProductCategoryIds: event.categoryIds,
      availableProductsOnly: event.availableOnly,
    ));
    final result = await getProductViewUseCase(
      ProductViewRequest(
        name: state.productSearchQuery.isEmpty
            ? null
            : state.productSearchQuery,
        categories: event.categoryIds,
        availableOnly: event.availableOnly,
        page: 0,
        size: EnvConfig.productPageSize,
        status: true,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        products: response.products,
        productCategories: response.categories,
        totalProducts: response.totalProducts,
      )),
    );
  }

  /// Obtiene el stock más reciente antes de abrir el formulario. El completer
  /// evita que la pantalla trabaje con el catálogo que tenía en memoria.
  Future<void> _refreshProductsForForm(
    RefreshOrderProducts event,
    Emitter<OrderState> emit,
  ) async {
    final result = await getProductViewUseCase(
      ProductViewRequest(
        page: 0,
        size: EnvConfig.productPageSize,
        status: true,
      ),
    );
    result.fold(
      (failure) => event.completer.completeError(StateError(failure.message)),
      (response) {
        emit(
          state.copyWith(
            products: response.products,
            productCategories: response.categories,
            totalProducts: response.totalProducts,
            productSearchQuery: '',
            selectedProductCategoryIds: const [],
            availableProductsOnly: false,
          ),
        );
        event.completer.complete(response.products);
      },
    );
  }

  Future<void> _saveOrder(SaveOrder event, Emitter<OrderState> emit) async {
    if (event.order.id == null) {
      final cashSessionResult = await existsOpenCashSessionUseCase();
      bool? isCashSessionOpen;

      cashSessionResult.fold(
        (failure) {
          if (event.completer?.isCompleted == false) {
            event.completer!.completeError(StateError(failure.message));
          }
          emit(
            state.copyWith(
              status: OrderStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (isOpen) {
          isCashSessionOpen = isOpen;
          emit(state.copyWith(isCashSessionOpen: isOpen));
        },
      );

      if (isCashSessionOpen != true) {
        if (isCashSessionOpen == false) {
          if (event.completer?.isCompleted == false) {
            event.completer!.completeError(
              StateError('Abra una caja antes de crear una orden.'),
            );
          }
          emit(
            state.copyWith(
              status: OrderStatus.failure,
              errorMessage: 'Abra una caja antes de crear una orden.',
            ),
          );
        }
        return;
      }
    }

    emit(state.copyWith(status: OrderStatus.loading));
    final result = event.order.id == null
        ? await createOrderUseCase(event.order)
        : await updateOrderUseCase(event.order.id!, event.order);
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(
          state.copyWith(
            status: OrderStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(
          emit,
          savedOrder: order,
          successMessage: event.order.id == null
              ? 'Orden creada correctamente.'
              : 'Orden actualizada correctamente.',
        );
      },
    );
  }

  Future<void> _changeStatus(
    ChangeOrderStatus event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await updateOrderStatusUseCase(event.id, event.status);
    await result.fold(
      (failure) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.completeError(StateError(failure.message));
        }
        emit(state.copyWith(
          status: OrderStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (order) async {
        if (event.completer?.isCompleted == false) {
          event.completer!.complete(order);
        }
        await _emitMutationSuccess(
          emit,
          savedOrder: order,
          successMessage: event.status == 'CANCELLED'
              ? 'Orden cancelada correctamente.'
              : 'Estado de la orden actualizado correctamente.',
        );
      },
    );
  }

  Future<void> _deleteOrder(DeleteOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await deleteOrderUseCase(event.id);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: OrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => _emitMutationSuccess(
        emit,
        deleted: true,
        successMessage: 'Orden eliminada correctamente.',
      ),
    );
  }

  Order _withIncidentDiscount(
    Order order,
    List<OrderItemIncident> incidents,
  ) => Order(
    id: order.id,
    orderNumber: order.orderNumber,
    cashRegisterId: order.cashRegisterId,
    orderType: order.orderType,
    tableNumber: order.tableNumber,
    status: order.status,
    notes: order.notes,
    items: order.items,
    incidentDiscount: incidents
        .where((incident) =>
            _isApprovedIncident(incident.status) &&
            order.items.any((item) =>
                item.id == incident.orderItemId && item.status != 'CANCELLED'))
        .fold(0.0, (total, incident) {
          if (incident.resolution == 'CANCEL_NO_CHARGE') {
            final matchingItems =
                order.items.where((item) => item.id == incident.orderItemId);
            return total +
                (matchingItems.isEmpty ? 0 : matchingItems.first.subtotal);
          }
          return total + (incident.resolution == 'DISCOUNT' ? incident.discountAmount : 0);
        }),
    nonChargeableItemIds: incidents
        .where((incident) => incident.resolution == 'CANCEL_NO_CHARGE' && _isApprovedIncident(incident.status))
        .map((incident) => incident.orderItemId)
        .whereType<int>()
        .toList(),
    incidentLockedItemIds: incidents
        .where((incident) => _isApprovedIncident(incident.status))
        .map((incident) => incident.orderItemId)
        .whereType<int>()
        .toSet()
        .toList(),
    createdAt: order.createdAt,
    modifiedAt: order.modifiedAt,
  );

  bool _isApprovedIncident(String status) {
    final normalized = status.trim().toUpperCase();
    return normalized == 'APPROVED' || normalized == 'APROVED';
  }

  /// Las mutaciones de una orden cambian el stock reservado. Sincronizamos
  /// ambos listados antes de notificar el éxito a la interfaz.
  Future<void> _emitMutationSuccess(
    Emitter<OrderState> emit, {
    Order? savedOrder,
    bool deleted = false,
    String? successMessage,
  }) async {
    if (savedOrder != null) {
      emit(state.copyWith(
        status: OrderStatus.success,
        savedOrder: savedOrder,
      ));
    }
    final ordersFuture = getOrdersUseCase(
      page: 0,
      size: EnvConfig.salesAndOrdersPageSize,
      from: state.fromDate,
      to: state.toDate,
      status: state.orderStatus,
      search: state.searchQuery,
      productId: state.productId,
    );
    final productsFuture = getProductViewUseCase(
      ProductViewRequest(
        page: 0,
        size: EnvConfig.productPageSize,
        status: true,
      ),
    );

    final ordersResult = await ordersFuture;
    final productsResult = await productsFuture;
    final refreshedOrders = ordersResult.fold(
      (_) => state.orders,
      (page) => page.orders,
    );
    // La consulta de lista usa un DTO resumido y puede llegar antes de que la
    // transacción de estado sea visible. Conservamos la orden recién mutada si
    // ya formaba parte de la lista para evitar que su card desaparezca.
    final synchronizedOrders = savedOrder == null ||
            refreshedOrders.any((order) => order.id == savedOrder.id) ||
            !state.orders.any((order) => order.id == savedOrder.id)
        ? refreshedOrders
        : [savedOrder!, ...refreshedOrders];
    final refreshedProducts = productsResult.fold(
      (_) => state.products,
      (response) => response.products,
    );

    emit(
      state.copyWith(
        status: OrderStatus.success,
        orders: synchronizedOrders,
        ordersPage: ordersResult.fold(
          (_) => state.ordersPage,
          (page) => page.page,
        ),
        hasMoreOrders: ordersResult.fold(
          (_) => state.hasMoreOrders,
          (page) => page.hasMore,
        ),
        products: refreshedProducts,
        totalProducts: productsResult.fold(
          (_) => state.totalProducts,
          (response) => response.totalProducts,
        ),
        savedOrder: null,
        deleted: deleted ? true : null,
        successMessage: successMessage,
      ),
    );
  }
}
