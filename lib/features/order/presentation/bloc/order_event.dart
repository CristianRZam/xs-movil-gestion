import 'dart:async';

import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => const [];
}

enum OrderDateFilter { all, today, week, month, custom }

class LoadOrders extends OrderEvent {
  final OrderDateFilter filter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String orderStatus;
  final String searchQuery;
  final int? productId;
  final String? productName;
  const LoadOrders({
    this.filter = OrderDateFilter.all,
    this.fromDate,
    this.toDate,
    this.orderStatus = 'ALL',
    this.searchQuery = '',
    this.productId,
    this.productName,
  });
  @override
  List<Object?> get props => [
    filter,
    fromDate,
    toDate,
    orderStatus,
    searchQuery,
    productId,
    productName,
  ];
}

class LoadMoreOrders extends OrderEvent {
  const LoadMoreOrders();
}

class LoadKitchenQueue extends OrderEvent {
  const LoadKitchenQueue();
}

class LoadOrderProducts extends OrderEvent {
  const LoadOrderProducts();
}

class LoadMoreOrderProducts extends OrderEvent {
  const LoadMoreOrderProducts();
}

class SearchOrderProducts extends OrderEvent {
  final String query;
  const SearchOrderProducts(this.query);
}

class FilterOrderProducts extends OrderEvent {
  const FilterOrderProducts({
    required this.categoryIds,
    required this.availableOnly,
  });

  final List<int> categoryIds;
  final bool availableOnly;

  @override
  List<Object?> get props => [categoryIds, availableOnly];
}

class RefreshOrderProducts extends OrderEvent {
  final Completer<List<Product>> completer;
  RefreshOrderProducts(this.completer);
}

class CheckOpenCashSession extends OrderEvent {
  const CheckOpenCashSession();
}

class SaveOrder extends OrderEvent {
  final Order order;
  final Completer<Order>? completer;

  const SaveOrder(this.order, {this.completer});
  @override
  List<Object?> get props => [order];
}

class ChangeOrderStatus extends OrderEvent {
  final int id;
  final String status;
  final Completer<Order>? completer;
  const ChangeOrderStatus(this.id, this.status, {this.completer});
  @override
  List<Object?> get props => [id, status];
}

class AddOrderItem extends OrderEvent {
  final int orderId;
  final OrderItem item;
  const AddOrderItem(this.orderId, this.item);
  @override
  List<Object?> get props => [orderId, item];
}

class AddOrderItems extends OrderEvent {
  const AddOrderItems(this.orderId, this.items, {this.completer});

  final int orderId;
  final List<OrderItem> items;
  final Completer<Order>? completer;

  @override
  List<Object?> get props => [orderId, items];
}

class UpdatePendingOrderItem extends OrderEvent {
  const UpdatePendingOrderItem(this.orderId, this.itemId, this.item, {this.completer});

  final int orderId;
  final int itemId;
  final OrderItem item;
  final Completer<Order>? completer;

  @override
  List<Object?> get props => [orderId, itemId, item];
}

class UpdateOrderCharges extends OrderEvent {
  const UpdateOrderCharges(
    this.orderId, {
    required this.packagingCharge,
    required this.deliveryCharge,
    this.completer,
  });

  final int orderId;
  final double packagingCharge;
  final double deliveryCharge;
  final Completer<Order>? completer;

  @override
  List<Object?> get props => [orderId, packagingCharge, deliveryCharge];
}

class SplitPendingOrderItem extends OrderEvent {
  const SplitPendingOrderItem(
    this.orderId,
    this.itemId,
    this.quantity,
    this.fulfillmentType, {
    this.completer,
  });

  final int orderId;
  final int itemId;
  final double quantity;
  final String fulfillmentType;
  final Completer<Order>? completer;

  @override
  List<Object?> get props => [orderId, itemId, quantity, fulfillmentType];
}

class ChangeOrderItemStatus extends OrderEvent {
  final int orderId;
  final int itemId;
  final String status;
  final String? comment;
  final bool fromKitchen;
  final Completer<Order>? completer;

  const ChangeOrderItemStatus(
    this.orderId,
    this.itemId,
    this.status, {
    this.comment,
    this.fromKitchen = false,
    this.completer,
  });

  @override
  List<Object?> get props => [orderId, itemId, status, comment, fromKitchen];
}

class ChangeOrderItemsStatus extends OrderEvent {
  final int orderId;
  final List<int> itemIds;
  final String status;
  final String? comment;
  final bool fromKitchen;
  final Completer<Order>? completer;
  const ChangeOrderItemsStatus(this.orderId, this.itemIds, this.status, {this.comment, this.fromKitchen = false, this.completer});
  @override
  List<Object?> get props => [orderId, itemIds, status, comment, fromKitchen];
}

class CancelPendingOrderItem extends OrderEvent {
  final int orderId;
  final int itemId;
  final String comment;
  final String stockDisposition;
  final Completer<Order>? completer;

  const CancelPendingOrderItem(
    this.orderId,
    this.itemId, {
    required this.comment,
    required this.stockDisposition,
    this.completer,
  });

  @override
  List<Object?> get props => [orderId, itemId, comment, stockDisposition];
}

class ReportOrderItemIncident extends OrderEvent {
  final int orderId;
  final int itemId;
  final String resolution;
  final String reason;
  final double? discountAmount;
  final Completer<Order>? completer;
  const ReportOrderItemIncident(
    this.orderId,
    this.itemId,
    this.resolution,
    this.reason, {
    this.discountAmount,
    this.completer,
  });
  @override
  List<Object?> get props => [orderId, itemId, resolution, reason, discountAmount];
}

class LoadOrderIncidents extends OrderEvent {
  final int orderId;
  const LoadOrderIncidents(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class DeleteOrder extends OrderEvent {
  final int id;
  const DeleteOrder(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearOrderAction extends OrderEvent {
  const ClearOrderAction();
}

class ClearOrderError extends OrderEvent {
  const ClearOrderError();
}
