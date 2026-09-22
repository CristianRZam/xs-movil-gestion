class DashboardSummary {
  final bool isPersonal;
  final DateTime? summaryDate;
  final int todaySalesCount;
  final double averageSale;
  final double todaySales;
  final int todayOrders;
  final List<DailySale> weeklySales;
  final List<TopProduct> topProducts;
  final List<PaymentMethodUsage> paymentMethods;

  const DashboardSummary({
    this.isPersonal = false,
    this.summaryDate,
    this.todaySalesCount = 0,
    this.averageSale = 0,
    required this.todaySales,
    required this.todayOrders,
    required this.weeklySales,
    required this.topProducts,
    required this.paymentMethods,
  });
}

class DailySale {
  final DateTime date;
  final double total;
  const DailySale({required this.date, required this.total});
}

class TopProduct {
  final int productId;
  final String productName;
  final int quantity;
  const TopProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
  });
}

class PaymentMethodUsage {
  final String method;
  final double total;
  const PaymentMethodUsage({required this.method, required this.total});
}
