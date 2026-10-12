import 'package:equatable/equatable.dart';

class OrderItemIncident extends Equatable {
  final int? id;
  final int orderItemId;
  final int productId;
  final String resolution;
  final String reason;
  final double discountAmount;
  final String status;
  final int? reportedBy;
  final DateTime? reportedAt;
  final int? approvedBy;
  final DateTime? approvedAt;
  const OrderItemIncident({this.id, required this.orderItemId, required this.productId, required this.resolution, required this.reason, this.discountAmount = 0, required this.status, this.reportedBy, this.reportedAt, this.approvedBy, this.approvedAt});
  @override List<Object?> get props => [id, orderItemId, productId, resolution, reason, discountAmount, status, reportedBy, reportedAt, approvedBy, approvedAt];
}
