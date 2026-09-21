// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductRequestModel _$ProductRequestModelFromJson(Map<String, dynamic> json) =>
    ProductRequestModel(
      id: (json['id'] as num?)?.toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
      unitMeasureId: (json['unitMeasureId'] as num).toInt(),
      valuationMethodId: (json['valuationMethodId'] as num).toInt(),
      basePrice: (json['basePrice'] as num).toDouble(),
      promoPrice: (json['promoPrice'] as num?)?.toDouble(),
      baseCost: (json['baseCost'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductRequestModelToJson(
  ProductRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'categoryId': instance.categoryId,
  'unitMeasureId': instance.unitMeasureId,
  'valuationMethodId': instance.valuationMethodId,
  'basePrice': instance.basePrice,
  'promoPrice': instance.promoPrice,
  'baseCost': instance.baseCost,
};
