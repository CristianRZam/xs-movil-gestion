// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  categoryId: (json['categoryId'] as num).toInt(),
  nameCategory: json['nameCategory'] as String,
  unitMeasureId: (json['unitMeasureId'] as num).toInt(),
  nameUnitMeasure: json['nameUnitMeasure'] as String,
  valuationMethodId: (json['valuationMethodId'] as num).toInt(),
  nameValuationMethod: json['nameValuationMethod'] as String,
  manageVariants: json['manageVariants'] as bool,
  basePrice: (json['basePrice'] as num).toDouble(),
  promoPrice: (json['promoPrice'] as num?)?.toDouble(),
  baseCost: (json['baseCost'] as num).toDouble(),
  totalStock: (json['totalStock'] as num).toInt(),
  reservedStock: (json['reservedStock'] as num).toInt(),
  active: json['active'] as bool,
  deleted: json['deleted'] as bool,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'nameCategory': instance.nameCategory,
      'unitMeasureId': instance.unitMeasureId,
      'nameUnitMeasure': instance.nameUnitMeasure,
      'valuationMethodId': instance.valuationMethodId,
      'nameValuationMethod': instance.nameValuationMethod,
      'manageVariants': instance.manageVariants,
      'basePrice': instance.basePrice,
      'promoPrice': instance.promoPrice,
      'baseCost': instance.baseCost,
      'totalStock': instance.totalStock,
      'reservedStock': instance.reservedStock,
      'active': instance.active,
      'deleted': instance.deleted,
    };
