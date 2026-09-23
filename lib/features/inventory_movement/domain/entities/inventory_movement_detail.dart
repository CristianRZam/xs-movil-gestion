class InventoryMovementDetail {
  // Movimiento
  final int id;
  final String type;
  final double quantity;
  final double previousStock;
  final double currentStock;
  final String? reason;
  final String? referenceType;
  final int? referenceId;
  final bool deleted;

  // Producto
  final int productId;
  final String productCode;
  final String productName;

  // Auditoría
  final DateTime createdAt;
  final String createdBy;
  final DateTime? modifiedAt;
  final String? modifiedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const InventoryMovementDetail({
    required this.id,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.currentStock,
    this.reason,
    this.referenceType,
    this.referenceId,
    required this.deleted,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.createdAt,
    required this.createdBy,
    this.modifiedAt,
    this.modifiedBy,
    this.deletedAt,
    this.deletedBy,
  });
}
