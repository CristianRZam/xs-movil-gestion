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
  final double incidentDiscount;
  final double packagingCharge;
  final double deliveryCharge;
  final List<int> nonChargeableItemIds;
  final List<int> incidentLockedItemIds;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String? createdByName;
  final bool hasNotes;
  final int? activeItemCount;
  final double? activeUnitCount;
  final double? totalAmount;
  final int? pendingItemCount;
  final int? preparingItemCount;
  final int? readyItemCount;
  final int? servedItemCount;
  final int? cancelledItemCount;

  const Order({
    this.id,
    required this.orderNumber,
    this.cashRegisterId,
    required this.orderType,
    this.tableNumber,
    this.status,
    this.notes,
    required this.items,
    this.incidentDiscount = 0,
    this.packagingCharge = 0,
    this.deliveryCharge = 0,
    this.nonChargeableItemIds = const [],
    this.incidentLockedItemIds = const [],
    this.createdAt,
    this.modifiedAt,
    this.createdByName,
    this.hasNotes = false,
    this.activeItemCount,
    this.activeUnitCount,
    this.totalAmount,
    this.pendingItemCount,
    this.preparingItemCount,
    this.readyItemCount,
    this.servedItemCount,
    this.cancelledItemCount,
  });

  double get total => totalAmount ?? (items
          .where((item) => item.status != 'CANCELLED')
          .fold(0.0, (sum, item) => sum + item.subtotal) -
          incidentDiscount + packagingCharge + deliveryCharge).clamp(0, double.infinity);
}
