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
    super.incidentDiscount,
    super.packagingCharge,
    super.deliveryCharge,
    super.nonChargeableItemIds,
    super.incidentLockedItemIds,
    super.createdAt,
    super.modifiedAt,
    super.createdByName,
    super.hasNotes,
    super.activeItemCount,
    super.activeUnitCount,
    super.totalAmount,
    super.pendingItemCount,
    super.preparingItemCount,
    super.readyItemCount,
    super.servedItemCount,
    super.cancelledItemCount,
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
    incidentDiscount: _asDouble(json['incidentDiscount']),
    packagingCharge: _asDouble(json['packagingCharge']),
    deliveryCharge: _asDouble(json['deliveryCharge']),
    nonChargeableItemIds: (json['nonChargeableItemIds'] as List<dynamic>? ?? const [])
        .map(_asInt)
        .whereType<int>()
        .toList(),
    incidentLockedItemIds: (json['incidentLockedItemIds'] as List<dynamic>? ?? const [])
        .map(_asInt)
        .whereType<int>()
        .toList(),
    createdAt: _asDate(json['createdAt']),
    modifiedAt: _asDate(json['modifiedAt']),
    createdByName: json['createdByName'] as String?,
    hasNotes: json['hasNotes'] as bool? ?? false,
    activeItemCount: _asInt(json['activeItemCount']),
    activeUnitCount: _asDoubleOrNull(json['activeUnitCount']),
    totalAmount: _asDoubleOrNull(json['totalAmount']),
    pendingItemCount: _asInt(json['pendingItemCount']),
    preparingItemCount: _asInt(json['preparingItemCount']),
    readyItemCount: _asInt(json['readyItemCount']),
    servedItemCount: _asInt(json['servedItemCount']),
    cancelledItemCount: _asInt(json['cancelledItemCount']),
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
    incidentDiscount: order.incidentDiscount,
    packagingCharge: order.packagingCharge,
    deliveryCharge: order.deliveryCharge,
    nonChargeableItemIds: order.nonChargeableItemIds,
    incidentLockedItemIds: order.incidentLockedItemIds,
    createdAt: order.createdAt,
    modifiedAt: order.modifiedAt,
    createdByName: order.createdByName,
    hasNotes: order.hasNotes,
    activeItemCount: order.activeItemCount,
    activeUnitCount: order.activeUnitCount,
    totalAmount: order.totalAmount,
    pendingItemCount: order.pendingItemCount,
    preparingItemCount: order.preparingItemCount,
    readyItemCount: order.readyItemCount,
    servedItemCount: order.servedItemCount,
    cancelledItemCount: order.cancelledItemCount,
  );

  Map<String, dynamic> toJson() => {
    'orderNumber': orderNumber,
    'orderType': orderType,
    'tableNumber': tableNumber,
    'notes': notes,
    'packagingCharge': packagingCharge,
    'deliveryCharge': deliveryCharge,
    'items': items
        .map((item) => OrderItemModel.fromEntity(item).toJson())
        .toList(),
  };
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    super.id,
    required super.productId,
    super.productName,
    required super.quantity,
    required super.unitPrice,
    super.notes,
    super.fulfillmentType,
    super.status,
    super.createdAt,
    super.modifiedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: _asInt(json['id']),
    productId: _asInt(json['productId']) ?? 0,
    productName: json['productName'] as String?,
    quantity: _asDouble(json['quantity']),
    unitPrice: _asDouble(json['unitPrice']),
    notes: json['notes'] as String?,
    fulfillmentType: json['fulfillmentType'] as String? ?? 'DINE_IN',
    status: json['status'] as String? ?? 'PENDING',
    createdAt: _asDate(json['createdAt']),
    modifiedAt: _asDate(json['modifiedAt']),
  );

  factory OrderItemModel.fromEntity(OrderItem item) => OrderItemModel(
    id: item.id,
    productId: item.productId,
    productName: item.productName,
    quantity: item.quantity,
    unitPrice: item.unitPrice,
    notes: item.notes,
    fulfillmentType: item.fulfillmentType,
    status: item.status,
    createdAt: item.createdAt,
    modifiedAt: item.modifiedAt,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'notes': notes,
    'fulfillmentType': fulfillmentType,
    'status': status,
  };
}

int? _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value');
double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
double? _asDoubleOrNull(dynamic value) =>
    value == null ? null : (value is num ? value.toDouble() : double.tryParse('$value'));
DateTime? _asDate(dynamic value) =>
    value == null ? null : DateTime.tryParse('$value');
