import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product_form_request.dart';

part 'product_form_request_model.g.dart';

@JsonSerializable()
class ProductFormRequestModel extends ProductFormRequest {

  const ProductFormRequestModel({
    super.id,
  });

  factory ProductFormRequestModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$ProductFormRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProductFormRequestModelToJson(this);

  factory ProductFormRequestModel.fromEntity(
      ProductFormRequest entity,
      ) {
    return ProductFormRequestModel(
      id: entity.id,
    );
  }
}