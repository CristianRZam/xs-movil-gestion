import 'package:app_movil_sistema/features/parameter/domain/entities/parameter.dart';
import 'package:app_movil_sistema/features/productimage/domain/entities/product_image.dart';
import 'product.dart';

class ProductFormResponse {
  final Product? product;
  final List<ProductImage> images;
  final List<Parameter> categories;
  final List<Parameter> unitMeasures;
  final List<Parameter> valuationMethods;

  const ProductFormResponse({
    this.product,
    required this.images,
    required this.categories,
    required this.unitMeasures,
    required this.valuationMethods,
  });
}
