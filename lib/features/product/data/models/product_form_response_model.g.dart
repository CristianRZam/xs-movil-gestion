// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_form_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductFormResponseModel _$ProductFormResponseModelFromJson(
  Map<String, dynamic> json,
) => ProductFormResponseModel(
  product: json['product'] == null
      ? null
      : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  unitMeasures:
      (json['unitMeasures'] as List<dynamic>?)
          ?.map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  valuationMethods:
      (json['valuationMethods'] as List<dynamic>?)
          ?.map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ProductFormResponseModelToJson(
  ProductFormResponseModel instance,
) => <String, dynamic>{
  'product': instance.product?.toJson(),
  'images': instance.images.map((e) => e.toJson()).toList(),
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'unitMeasures': instance.unitMeasures.map((e) => e.toJson()).toList(),
  'valuationMethods': instance.valuationMethods.map((e) => e.toJson()).toList(),
};
