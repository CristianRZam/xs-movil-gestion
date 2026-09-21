import 'order_item.dart';

class Order {
  final int? id;
  final String orderNumber;
  final int? cashRegisterId;
  final String orderType;
  final String? tableNumber;
  final String? status;
  final String? notes;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? modifiedAt;

  const Order({
    this.id,
    required this.orderNumber,
    this.cashRegisterId,
    required this.orderType,
    this.tableNumber,
    this.status,
    this.notes,
    required this.items,
    this.createdAt,
    this.modifiedAt,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
}
