class DashboardSummary {
  final DateTime? summaryDate;
  final int todaySalesCount;
  final double averageSale;
  final double todaySales;
  final int todayOrders;
  final List<DailySale> weeklySales;
  final List<TopProduct> topProducts;
  final List<PaymentMethodUsage> paymentMethods;
  final String scope;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? sellerId;

  const DashboardSummary({
    this.summaryDate,
    this.todaySalesCount = 0,
    this.averageSale = 0,
    required this.todaySales,
    required this.todayOrders,
    required this.weeklySales,
    required this.topProducts,
    required this.paymentMethods,
    this.scope = 'GLOBAL',
    this.fromDate,
    this.toDate,
    this.sellerId,
  });
}

class DashboardFilter {
  const DashboardFilter({
    required this.fromDate,
    required this.toDate,
    this.scope = 'GLOBAL',
    this.sellerId,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final String scope;
  final int? sellerId;

  DashboardFilter copyWith({DateTime? fromDate, DateTime? toDate, String? scope, int? sellerId, bool clearSeller = false}) => DashboardFilter(
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
        scope: scope ?? this.scope,
        sellerId: clearSeller ? null : sellerId ?? this.sellerId,
      );
}

class DashboardSeller {
  const DashboardSeller({required this.id, required this.name});
  final int id;
  final String name;
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
