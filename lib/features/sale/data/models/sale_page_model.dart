import '../../domain/entities/sale_page.dart';
import 'sale_model.dart';

class SalePageModel {
  const SalePageModel({
    required this.sales,
    required this.totalElements,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  final List<SaleModel> sales;
  final int totalElements;
  final int page;
  final int size;
  final bool hasMore;

  factory SalePageModel.fromJson(Map<String, dynamic> json) => SalePageModel(
    sales: (json['items'] as List<dynamic>? ?? const [])
        .map((item) => SaleModel.fromJson(item as Map<String, dynamic>))
        .toList(),
    totalElements: (json['totalElements'] as num? ?? 0).toInt(),
    page: (json['page'] as num? ?? 0).toInt(),
    size: (json['size'] as num? ?? 0).toInt(),
    hasMore: json['hasMore'] as bool? ?? false,
  );

  SalePage toEntity() => SalePage(
    sales: sales,
    totalElements: totalElements,
    page: page,
    size: size,
    hasMore: hasMore,
  );
}
