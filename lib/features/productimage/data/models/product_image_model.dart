import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product_image.dart';

part 'product_image_model.g.dart';

@JsonSerializable()
class ProductImageModel extends ProductImage {

  const ProductImageModel({
    required super.id,
    required super.imageUrl,
    required super.altText,
    required super.isMain,
    required super.orderNumber,
  });

  factory ProductImageModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$ProductImageModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProductImageModelToJson(this);

  factory ProductImageModel.fromEntity(
      ProductImage entity,
      ) {
    return ProductImageModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      altText: entity.altText,
      isMain: entity.isMain,
      orderNumber: entity.orderNumber,
    );
  }

}