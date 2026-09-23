import '../../domain/entities/order_page.dart';
import 'order_model.dart';

class OrderPageModel {
  const OrderPageModel({
    required this.orders,
    required this.totalElements,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  final List<OrderModel> orders;
  final int totalElements;
  final int page;
  final int size;
  final bool hasMore;

  factory OrderPageModel.fromJson(Map<String, dynamic> json) => OrderPageModel(
    orders: (json['items'] as List<dynamic>? ?? const [])
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList(),
    totalElements: (json['totalElements'] as num? ?? 0).toInt(),
    page: (json['page'] as num? ?? 0).toInt(),
    size: (json['size'] as num? ?? 0).toInt(),
    hasMore: json['hasMore'] as bool? ?? false,
  );

  OrderPage toEntity() => OrderPage(
    orders: orders,
    totalElements: totalElements,
    page: page,
    size: size,
    hasMore: hasMore,
  );
}
