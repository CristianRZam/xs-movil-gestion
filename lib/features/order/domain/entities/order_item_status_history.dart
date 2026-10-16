class OrderItemStatusHistory {
  const OrderItemStatusHistory({
    required this.id,
    required this.orderItemId,
    this.previousStatus,
    required this.newStatus,
    this.comment,
    this.changedBy,
    this.changedByName,
    required this.changedAt,
  });

  final int? id;
  final int orderItemId;
  final String? previousStatus;
  final String newStatus;
  final String? comment;
  final int? changedBy;
  final String? changedByName;
  final DateTime? changedAt;
}
