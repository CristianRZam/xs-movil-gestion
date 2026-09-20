import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session_close_request.dart';

class CashSessionCloseRequestModel {

  final int id;
  final double closingAmount;
  final double expectedAmount;
  final double? difference;
  final String? closingComment;

  CashSessionCloseRequestModel({
    required this.id,
    required this.closingAmount,
    required this.expectedAmount,
    this.difference,
    this.closingComment,
  });

  factory CashSessionCloseRequestModel.fromEntity(
      CashSessionCloseRequest entity,
      ) {
    return CashSessionCloseRequestModel(
      id: entity.id,
      closingAmount: entity.closingAmount,
      expectedAmount: entity.expectedAmount,
      difference: entity.difference,
      closingComment: entity.closingComment,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'closingAmount': closingAmount,
      'expectedAmount': expectedAmount,
      if (difference != null)
        'difference': difference,
      if (closingComment != null &&
          closingComment!.isNotEmpty)
        'closingComment': closingComment,
    };
  }
}