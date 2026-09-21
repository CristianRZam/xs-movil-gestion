class OrderItem {
  final int? id;
  final int productId;
  final double quantity;
  final double unitPrice;
  final String? notes;
  final DateTime? createdAt;

  const OrderItem({
    this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    this.createdAt,
  });

  double get subtotal => quantity * unitPrice;
}
