import 'dart:async';

import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
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
  const LoadOrders({
    this.filter = OrderDateFilter.all,
    this.fromDate,
    this.toDate,
    this.orderStatus = 'ALL',
    this.searchQuery = '',
  });
  @override
  List<Object?> get props => [
    filter,
    fromDate,
    toDate,
    orderStatus,
    searchQuery,
  ];
}

class LoadMoreOrders extends OrderEvent {
  const LoadMoreOrders();
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

class RefreshOrderProducts extends OrderEvent {
  final Completer<List<Product>> completer;
  RefreshOrderProducts(this.completer);
}

class CheckOpenCashSession extends OrderEvent {
  const CheckOpenCashSession();
}

class SaveOrder extends OrderEvent {
  final Order order;
  const SaveOrder(this.order);
  @override
  List<Object?> get props => [order];
}

class ChangeOrderStatus extends OrderEvent {
  final int id;
  final String status;
  const ChangeOrderStatus(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
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
