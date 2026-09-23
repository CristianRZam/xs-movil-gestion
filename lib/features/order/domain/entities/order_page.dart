import 'order.dart';

class OrderPage {
  const OrderPage({
    required this.orders,
    required this.totalElements,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  final List<Order> orders;
  final int totalElements;
  final int page;
  final int size;
  final bool hasMore;
}
