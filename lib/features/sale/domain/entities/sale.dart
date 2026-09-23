class SaleItem {
  final int productId;
  final String? productName;
  final double quantity;
  final double unitPrice;
  final double discount;
  const SaleItem({
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });
  double get subtotal => quantity * unitPrice - discount;
}

class SalePayment {
  final String paymentMethod;
  final double amount;
  final String? reference;
  const SalePayment({
    required this.paymentMethod,
    required this.amount,
    this.reference,
  });
}

class Sale {
  final int? id;
  final String saleNumber;
  final int? orderId;
  final double discount;
  final String? status;
  final int? createdBy;
  final String? createdByName;
  final String? cancellationReason;
  final int? cancelledBy;
  final String? cancelledByName;
  final DateTime? cancelledAt;
  final List<SaleItem> items;
  final List<SalePayment> payments;
  const Sale({
    this.id,
    required this.saleNumber,
    this.orderId,
    this.discount = 0,
    this.status,
    this.createdBy,
    this.createdByName,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledByName,
    this.cancelledAt,
    required this.items,
    required this.payments,
  });
  double get total =>
      items.fold<double>(0, (sum, item) => sum + item.subtotal) - discount;
}
