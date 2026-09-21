import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';

class PaymentMethodTotal {
  final String paymentMethod;
  final double total;
  const PaymentMethodTotal({required this.paymentMethod, required this.total});
}

class CashSessionSalesSummary {
  final int cashSessionId;
  final double totalSold;
  final List<PaymentMethodTotal> paymentMethods;
  final List<Sale> sales;
  const CashSessionSalesSummary({required this.cashSessionId, required this.totalSold, required this.paymentMethods, required this.sales});
}
