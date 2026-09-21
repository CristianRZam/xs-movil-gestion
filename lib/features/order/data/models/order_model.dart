import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';

class OrderModel extends Order {
  const OrderModel({
    super.id,
    required super.orderNumber,
    super.cashRegisterId,
    required super.orderType,
    super.tableNumber,
    super.status,
    super.notes,
    required super.items,
    super.createdAt,
    super.modifiedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: _asInt(json['id']),
        orderNumber: json['orderNumber'] as String? ?? '',
        cashRegisterId: _asInt(json['cashRegisterId']),
        orderType: json['orderType'] as String? ?? 'DINE_IN',
        tableNumber: json['tableNumber'] as String?,
        status: json['status'] as String?,
        notes: json['notes'] as String?,
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        createdAt: _asDate(json['createdAt']),
        modifiedAt: _asDate(json['modifiedAt']),
      );

  factory OrderModel.fromEntity(Order order) => OrderModel(
        id: order.id,
        orderNumber: order.orderNumber,
        cashRegisterId: order.cashRegisterId,
        orderType: order.orderType,
        tableNumber: order.tableNumber,
        status: order.status,
        notes: order.notes,
        items: order.items,
        createdAt: order.createdAt,
        modifiedAt: order.modifiedAt,
      );

  Map<String, dynamic> toJson() => {
        'orderNumber': orderNumber,
        'orderType': orderType,
        'tableNumber': tableNumber,
        'notes': notes,
        'items': items.map((item) => OrderItemModel.fromEntity(item).toJson()).toList(),
      };
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    super.id,
    required super.productId,
    required super.quantity,
    required super.unitPrice,
    super.notes,
    super.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: _asInt(json['id']),
        productId: _asInt(json['productId']) ?? 0,
        quantity: _asDouble(json['quantity']),
        unitPrice: _asDouble(json['unitPrice']),
        notes: json['notes'] as String?,
        createdAt: _asDate(json['createdAt']),
      );

  factory OrderItemModel.fromEntity(OrderItem item) => OrderItemModel(
        id: item.id,
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        notes: item.notes,
        createdAt: item.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'notes': notes,
      };
}

int? _asInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value');
double _asDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
DateTime? _asDate(dynamic value) => value == null ? null : DateTime.tryParse('$value');
