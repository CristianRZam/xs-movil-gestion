import 'package:app_movil_sistema/features/parameter/domain/entities/parameter.dart';

import 'product.dart';

class ProductViewResponse {
  final List<Product> products;
  final int totalProducts;
  final int activeProducts;
  final int inactiveProducts;
  final int totalStock;
  final List<Parameter> categories;
  final List<Parameter> unitMeasures;
  final List<Parameter> valuationMethods;

  const ProductViewResponse({
    required this.products,
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.totalStock,
    required this.categories,
    required this.unitMeasures,
    required this.valuationMethods,
  });
}
