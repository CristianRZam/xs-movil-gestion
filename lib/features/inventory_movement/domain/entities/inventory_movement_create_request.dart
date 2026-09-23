class InventoryMovementCreateRequest {
  final int productId;
  final String type;
  final double quantity;
  final double previousStock;
  final double currentStock;
  final String? reason;
  final String? referenceType;
  final int? referenceId;

  const InventoryMovementCreateRequest({
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.currentStock,
    this.reason,
    this.referenceType,
    this.referenceId,
  });
}
