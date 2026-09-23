import 'package:app_movil_sistema/features/productimage/data/models/product_image_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../parameter/data/models/parameter_model.dart';
import '../../domain/entities/product_form_response.dart';
import 'product_model.dart';

part 'product_form_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductFormResponseModel {
  final ProductModel? product;

  @JsonKey(defaultValue: <ProductImageModel>[])
  final List<ProductImageModel> images;

  @JsonKey(defaultValue: <ParameterModel>[])
  final List<ParameterModel> categories;

  @JsonKey(defaultValue: <ParameterModel>[])
  final List<ParameterModel> unitMeasures;

  @JsonKey(defaultValue: <ParameterModel>[])
  final List<ParameterModel> valuationMethods;

  const ProductFormResponseModel({
    this.product,
    required this.images,
    required this.categories,
    required this.unitMeasures,
    required this.valuationMethods,
  });

  factory ProductFormResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductFormResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductFormResponseModelToJson(this);

  ProductFormResponse toEntity() {
    return ProductFormResponse(
      product: product,
      images: images,
      categories: categories,
      unitMeasures: unitMeasures,
      valuationMethods: valuationMethods,
    );
  }

  factory ProductFormResponseModel.fromEntity(ProductFormResponse entity) {
    return ProductFormResponseModel(
      product: entity.product != null
          ? ProductModel.fromEntity(entity.product!)
          : null,
      images: entity.images.map(ProductImageModel.fromEntity).toList(),
      categories: entity.categories.map(ParameterModel.fromEntity).toList(),
      unitMeasures: entity.unitMeasures.map(ParameterModel.fromEntity).toList(),
      valuationMethods: entity.valuationMethods
          .map(ParameterModel.fromEntity)
          .toList(),
    );
  }
}
