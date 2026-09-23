import 'sale.dart';

class SalePage {
  const SalePage({
    required this.sales,
    required this.totalElements,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  final List<Sale> sales;
  final int totalElements;
  final int page;
  final int size;
  final bool hasMore;
}
