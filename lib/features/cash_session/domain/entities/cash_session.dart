class CashSession {

  final int id;
  final int cashRegisterId;
  final int openedBy;
  final String? openedByName;
  final DateTime openedAt;
  final double openingAmount;
  final int? closedBy;
  final String? closedByName;
  final DateTime? closedAt;
  final double? expectedAmount;
  final double? closingAmount;
  final double? difference;
  final String status;
  final String? openingComment;
  final String? closingComment;
  final int? createdBy;
  final DateTime? createdAt;
  final int? modifiedBy;
  final DateTime? modifiedAt;
  final bool deleted;

  const CashSession({
    required this.id,
    required this.cashRegisterId,
    required this.openedBy,
    this.openedByName,
    required this.openedAt,
    required this.openingAmount,
    this.closedBy,
    this.closedByName,
    this.closedAt,
    this.expectedAmount,
    this.closingAmount,
    this.difference,
    required this.status,
    this.openingComment,
    this.closingComment,
    this.createdBy,
    this.createdAt,
    this.modifiedBy,
    this.modifiedAt,
    required this.deleted,
  });
}