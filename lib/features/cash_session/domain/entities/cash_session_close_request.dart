class CashSessionCloseRequest {

  final int id;
  final double closingAmount;
  final double expectedAmount;
  final double? difference;
  final String? closingComment;

  const CashSessionCloseRequest({
    required this.id,
    required this.closingAmount,
    required this.expectedAmount,
    this.difference,
    this.closingComment,
  });
}