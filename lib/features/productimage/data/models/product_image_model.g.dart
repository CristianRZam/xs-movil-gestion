// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductImageModel _$ProductImageModelFromJson(Map<String, dynamic> json) =>
    ProductImageModel(
      id: (json['id'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      altText: json['altText'] as String,
      isMain: json['isMain'] as bool,
      orderNumber: (json['orderNumber'] as num).toInt(),
    );

Map<String, dynamic> _$ProductImageModelToJson(ProductImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'altText': instance.altText,
      'isMain': instance.isMain,
      'orderNumber': instance.orderNumber,
    };
