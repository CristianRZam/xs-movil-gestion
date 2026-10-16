import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item_incident.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/parameter/domain/entities/parameter.dart';
import 'order_event.dart';

enum OrderStatus { initial, loading, success, failure }

class OrderState {
  final OrderStatus status;
  final List<Order> orders;
  final List<Order> kitchenOrders;
  final List<Product> products;
  final List<Parameter> productCategories;
  final String productSearchQuery;
  final List<int> selectedProductCategoryIds;
  final bool availableProductsOnly;
  final bool? isCashSessionOpen;
  final Order? savedOrder;
  final bool? deleted;
  final String? errorMessage;
  final String? successMessage;
  final int totalProducts;
  final bool isLoadingMoreProducts;
  final int ordersPage;
  final bool hasMoreOrders;
  final bool isLoadingMoreOrders;
  final OrderDateFilter dateFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String orderStatus;
  final String searchQuery;
  final int? productId;
  final String? productName;
  final List<OrderItemIncident> incidents;
  final int? incidentsOrderId;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.kitchenOrders = const [],
    this.products = const [],
    this.productCategories = const [],
    this.productSearchQuery = '',
    this.selectedProductCategoryIds = const [],
    this.availableProductsOnly = false,
    this.isCashSessionOpen,
    this.savedOrder,
    this.deleted,
    this.errorMessage,
    this.successMessage,
    this.totalProducts = 0,
    this.isLoadingMoreProducts = false,
    this.ordersPage = 0,
    this.hasMoreOrders = false,
    this.isLoadingMoreOrders = false,
    this.dateFilter = OrderDateFilter.all,
    this.fromDate,
    this.toDate,
    this.orderStatus = 'ALL',
    this.searchQuery = '',
    this.productId,
    this.productName,
    this.incidents = const [],
    this.incidentsOrderId,
  });

  bool get hasMoreProducts => products.length < totalProducts;

  OrderState copyWith({
    OrderStatus? status,
    List<Order>? orders,
    List<Order>? kitchenOrders,
    List<Product>? products,
    List<Parameter>? productCategories,
    String? productSearchQuery,
    List<int>? selectedProductCategoryIds,
    bool? availableProductsOnly,
    Object? isCashSessionOpen = _sentinel,
    Object? savedOrder = _sentinel,
    Object? deleted = _sentinel,
    Object? errorMessage = _sentinel,
    Object? successMessage = _sentinel,
    int? totalProducts,
    bool? isLoadingMoreProducts,
    int? ordersPage,
    bool? hasMoreOrders,
    bool? isLoadingMoreOrders,
    OrderDateFilter? dateFilter,
    Object? fromDate = _sentinel,
    Object? toDate = _sentinel,
    String? orderStatus,
    String? searchQuery,
    Object? productId = _sentinel,
    Object? productName = _sentinel,
    List<OrderItemIncident>? incidents,
    Object? incidentsOrderId = _sentinel,
  }) => OrderState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    kitchenOrders: kitchenOrders ?? this.kitchenOrders,
    products: products ?? this.products,
    productCategories: productCategories ?? this.productCategories,
    productSearchQuery: productSearchQuery ?? this.productSearchQuery,
    selectedProductCategoryIds:
        selectedProductCategoryIds ?? this.selectedProductCategoryIds,
    availableProductsOnly:
        availableProductsOnly ?? this.availableProductsOnly,
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
    successMessage: identical(successMessage, _sentinel)
        ? this.successMessage
        : successMessage as String?,
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
    orderStatus: orderStatus ?? this.orderStatus,
    searchQuery: searchQuery ?? this.searchQuery,
    productId: identical(productId, _sentinel) ? this.productId : productId as int?,
    productName: identical(productName, _sentinel) ? this.productName : productName as String?,
    incidents: incidents ?? this.incidents,
    incidentsOrderId: identical(incidentsOrderId, _sentinel) ? this.incidentsOrderId : incidentsOrderId as int?,
  );
  static const _sentinel = Object();
}
