import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';

enum OrderStatus { initial, loading, success, failure }

class OrderState {
  final OrderStatus status;
  final List<Order> orders;
  final List<Product> products;
  final bool? isCashSessionOpen;
  final Order? savedOrder;
  final bool? deleted;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.products = const [],
    this.isCashSessionOpen,
    this.savedOrder,
    this.deleted,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatus? status,
    List<Order>? orders,
    List<Product>? products,
    Object? isCashSessionOpen = _sentinel,
    Object? savedOrder = _sentinel,
    Object? deleted = _sentinel,
    Object? errorMessage = _sentinel,
  }) => OrderState(
        status: status ?? this.status,
        orders: orders ?? this.orders,
        products: products ?? this.products,
        isCashSessionOpen: identical(isCashSessionOpen, _sentinel)
            ? this.isCashSessionOpen
            : isCashSessionOpen as bool?,
        savedOrder: identical(savedOrder, _sentinel) ? this.savedOrder : savedOrder as Order?,
        deleted: identical(deleted, _sentinel) ? this.deleted : deleted as bool?,
        errorMessage: identical(errorMessage, _sentinel) ? this.errorMessage : errorMessage as String?,
      );
  static const _sentinel = Object();
}
