import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product_request.dart';
import 'dart:convert';

part 'product_request_model.g.dart';

@JsonSerializable()
class ProductRequestModel extends ProductRequest {

  const ProductRequestModel({
    super.id,
    required super.code,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.unitMeasureId,
    required super.valuationMethodId,
    required super.basePrice,
    super.promoPrice,
    required super.baseCost,
  });

  factory ProductRequestModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$ProductRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProductRequestModelToJson(this);

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory ProductRequestModel.fromEntity(
      ProductRequest entity,
      ) {
    return ProductRequestModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      categoryId: entity.categoryId,
      unitMeasureId: entity.unitMeasureId,
      valuationMethodId: entity.valuationMethodId,
      basePrice: entity.basePrice,
      promoPrice: entity.promoPrice,
      baseCost: entity.baseCost,
    );
  }
}