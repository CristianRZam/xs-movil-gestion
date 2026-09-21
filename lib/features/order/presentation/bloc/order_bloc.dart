import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/usecases/order_usecases.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrdersUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final UpdateOrderUseCase updateOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final DeleteOrderUseCase deleteOrderUseCase;
  final GetProductViewUseCase getProductViewUseCase;
  final ExistsOpenCashSessionUseCase existsOpenCashSessionUseCase;

  OrderBloc(this.getOrdersUseCase, this.createOrderUseCase, this.updateOrderUseCase,
      this.updateOrderStatusUseCase, this.deleteOrderUseCase, this.getProductViewUseCase,
      this.existsOpenCashSessionUseCase)
      : super(const OrderState()) {
    on<LoadOrders>(_loadOrders);
    on<LoadOrderProducts>(_loadProducts);
    on<RefreshOrderProducts>(_refreshProductsForForm);
    on<CheckOpenCashSession>(_checkOpenCashSession);
    on<SaveOrder>(_saveOrder);
    on<ChangeOrderStatus>(_changeStatus);
    on<DeleteOrder>(_deleteOrder);
    on<ClearOrderAction>((_, emit) => emit(state.copyWith(savedOrder: null, deleted: null)));
    on<ClearOrderError>((_, emit) => emit(state.copyWith(status: OrderStatus.success, errorMessage: null)));
  }

  Future<void> _checkOpenCashSession(
      CheckOpenCashSession event,
      Emitter<OrderState> emit,
      ) async {
    final result = await existsOpenCashSessionUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        isCashSessionOpen: false,
        errorMessage: failure.message,
      )),
      (isOpen) => emit(state.copyWith(isCashSessionOpen: isOpen)),
    );
  }

  Future<void> _loadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await getOrdersUseCase();
    result.fold(
      (failure) => emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message)),
      (orders) => emit(state.copyWith(status: OrderStatus.success, orders: orders)),
    );
  }

  Future<void> _loadProducts(LoadOrderProducts event, Emitter<OrderState> emit) async {
    final result = await getProductViewUseCase(const ProductViewRequest(page: 0, size: 1000, status: true));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (response) => emit(state.copyWith(products: response.products)),
    );
  }

  /// Obtiene el stock más reciente antes de abrir el formulario. El completer
  /// evita que la pantalla trabaje con el catálogo que tenía en memoria.
  Future<void> _refreshProductsForForm(
    RefreshOrderProducts event,
    Emitter<OrderState> emit,
  ) async {
    final result = await getProductViewUseCase(
      const ProductViewRequest(page: 0, size: 1000, status: true),
    );
    result.fold(
      (failure) => event.completer.completeError(StateError(failure.message)),
      (response) {
        emit(state.copyWith(products: response.products));
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
          emit(state.copyWith(
            status: OrderStatus.failure,
            errorMessage: failure.message,
          ));
        },
        (isOpen) {
          isCashSessionOpen = isOpen;
          emit(state.copyWith(isCashSessionOpen: isOpen));
        },
      );

      if (isCashSessionOpen != true) {
        if (isCashSessionOpen == false) {
          emit(state.copyWith(
            status: OrderStatus.failure,
            errorMessage: 'Abra una caja antes de crear una orden.',
          ));
        }
        return;
      }
    }

    emit(state.copyWith(status: OrderStatus.loading));
    final result = event.order.id == null
        ? await createOrderUseCase(event.order)
        : await updateOrderUseCase(event.order.id!, event.order);
    await result.fold(
      (failure) async => emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message)),
      (order) => _emitMutationSuccess(emit, savedOrder: order),
    );
  }

  Future<void> _changeStatus(ChangeOrderStatus event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await updateOrderStatusUseCase(event.id, event.status);
    await result.fold(
      (failure) async => emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message)),
      (order) => _emitMutationSuccess(emit, savedOrder: order),
    );
  }

  Future<void> _deleteOrder(DeleteOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    final result = await deleteOrderUseCase(event.id);
    await result.fold(
      (failure) async => emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message)),
      (_) => _emitMutationSuccess(emit, deleted: true),
    );
  }

  /// Las mutaciones de una orden cambian el stock reservado. Sincronizamos
  /// ambos listados antes de notificar el éxito a la interfaz.
  Future<void> _emitMutationSuccess(
    Emitter<OrderState> emit, {
    Order? savedOrder,
    bool deleted = false,
  }) async {
    final ordersResult = await getOrdersUseCase();
    final productsResult = await getProductViewUseCase(
      const ProductViewRequest(page: 0, size: 1000, status: true),
    );

    final refreshedOrders = ordersResult.fold((_) => state.orders, (orders) => orders);
    final refreshedProducts = productsResult.fold(
      (_) => state.products,
      (response) => response.products,
    );

    emit(state.copyWith(
      status: OrderStatus.success,
      orders: refreshedOrders,
      products: refreshedProducts,
      savedOrder: savedOrder,
      deleted: deleted ? true : null,
    ));
  }
}
