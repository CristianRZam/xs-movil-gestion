import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'order_event.dart';

enum OrderStatus { initial, loading, success, failure }

class OrderState {
  final OrderStatus status;
  final List<Order> orders;
  final List<Product> products;
  final bool? isCashSessionOpen;
  final Order? savedOrder;
  final bool? deleted;
  final String? errorMessage;
  final int totalProducts;
  final bool isLoadingMoreProducts;
  final int ordersPage;
  final bool hasMoreOrders;
  final bool isLoadingMoreOrders;
  final OrderDateFilter dateFilter;
  final DateTime? fromDate;
  final DateTime? toDate;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.products = const [],
    this.isCashSessionOpen,
    this.savedOrder,
    this.deleted,
    this.errorMessage,
    this.totalProducts = 0,
    this.isLoadingMoreProducts = false,
    this.ordersPage = 0,
    this.hasMoreOrders = false,
    this.isLoadingMoreOrders = false,
    this.dateFilter = OrderDateFilter.all,
    this.fromDate,
    this.toDate,
  });

  bool get hasMoreProducts => products.length < totalProducts;

  OrderState copyWith({
    OrderStatus? status,
    List<Order>? orders,
    List<Product>? products,
    Object? isCashSessionOpen = _sentinel,
    Object? savedOrder = _sentinel,
    Object? deleted = _sentinel,
    Object? errorMessage = _sentinel,
    int? totalProducts,
    bool? isLoadingMoreProducts,
    int? ordersPage,
    bool? hasMoreOrders,
    bool? isLoadingMoreOrders,
    OrderDateFilter? dateFilter,
    Object? fromDate = _sentinel,
    Object? toDate = _sentinel,
  }) => OrderState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    products: products ?? this.products,
    isCashSessionOpen: identical(isCashSessionOpen, _sentinel)
        ? this.isCashSessionOpen
        : isCashSessionOpen as bool?,
    savedOrder: identical(savedOrder, _sentinel)
        ? this.savedOrder
        : savedOrder as Order?,
    deleted: identical(deleted, _sentinel) ? this.deleted : deleted as bool?,
    errorMessage: identical(errorMessage, _sentinel)
        ? this.errorMessage
        : errorMessage as String?,
    totalProducts: totalProducts ?? this.totalProducts,
    isLoadingMoreProducts: isLoadingMoreProducts ?? this.isLoadingMoreProducts,
    ordersPage: ordersPage ?? this.ordersPage,
    hasMoreOrders: hasMoreOrders ?? this.hasMoreOrders,
    isLoadingMoreOrders: isLoadingMoreOrders ?? this.isLoadingMoreOrders,
    dateFilter: dateFilter ?? this.dateFilter,
    fromDate: identical(fromDate, _sentinel)
        ? this.fromDate
        : fromDate as DateTime?,
    toDate: identical(toDate, _sentinel) ? this.toDate : toDate as DateTime?,
  );
  static const _sentinel = Object();
}
