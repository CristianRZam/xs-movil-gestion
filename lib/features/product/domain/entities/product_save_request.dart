import 'package:app_movil_sistema/features/product/domain/entities/product_request.dart';
import 'package:app_movil_sistema/features/productimage/domain/entities/product_image.dart';

class ProductImageUpload {
  final String path;
  final String fileName;

  const ProductImageUpload({required this.path, required this.fileName});
}

class ProductSaveRequest {
  final ProductRequest product;
  final List<ProductImageUpload> newImages;
  final List<ProductImage> imagesToKeep;
  final String? mainImageKey;

  const ProductSaveRequest({
    required this.product,
    this.newImages = const [],
    this.imagesToKeep = const [],
    this.mainImageKey,
  });
}
