import 'product_category.dart';

class CategoryUpdateRequest {
  const CategoryUpdateRequest({
    required this.category,
    required this.name,
    required this.shortName,
    required this.orderNumber,
  });

  final ProductCategory category;
  final String name;
  final String? shortName;
  final int orderNumber;
}
