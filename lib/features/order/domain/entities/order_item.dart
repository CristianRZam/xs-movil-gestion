class OrderItem {
  final int? id;
  final int productId;
  final String? productName;
  final double quantity;
  final double unitPrice;
  final String? notes;
  final String fulfillmentType;
  final String status;
  final DateTime? createdAt;
  final DateTime? modifiedAt;

  const OrderItem({
    this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    this.fulfillmentType = 'DINE_IN',
    this.status = 'PENDING',
    this.createdAt,
    this.modifiedAt,
  });

  double get subtotal => quantity * unitPrice;
}
