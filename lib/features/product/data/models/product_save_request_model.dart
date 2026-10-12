import 'package:app_movil_sistema/features/product/data/models/product_request_model.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_save_request.dart';
import 'package:app_movil_sistema/features/productimage/domain/entities/product_image.dart';

class ProductSaveRequestModel {
  final ProductRequestModel product;
  final List<ProductImageUpload> newImages;
  final List<ProductImage> imagesToKeep;
  final String? mainImageKey;

  const ProductSaveRequestModel({
    required this.product,
    required this.newImages,
    required this.imagesToKeep,
    this.mainImageKey,
  });

  factory ProductSaveRequestModel.fromEntity(ProductSaveRequest entity) {
    return ProductSaveRequestModel(
      product: ProductRequestModel.fromEntity(entity.product),
      newImages: entity.newImages,
      imagesToKeep: entity.imagesToKeep,
      mainImageKey: entity.mainImageKey,
    );
  }
}
