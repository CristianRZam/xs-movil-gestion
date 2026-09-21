// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryMovementCreateRequestModel
_$InventoryMovementCreateRequestModelFromJson(Map<String, dynamic> json) =>
    InventoryMovementCreateRequestModel(
      productId: (json['productId'] as num).toInt(),
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      previousStock: (json['previousStock'] as num).toDouble(),
      currentStock: (json['currentStock'] as num).toDouble(),
      reason: json['reason'] as String?,
      referenceType: json['referenceType'] as String?,
      referenceId: (json['referenceId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InventoryMovementCreateRequestModelToJson(
  InventoryMovementCreateRequestModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'type': instance.type,
  'quantity': instance.quantity,
  'previousStock': instance.previousStock,
  'currentStock': instance.currentStock,
  'reason': instance.reason,
  'referenceType': instance.referenceType,
  'referenceId': instance.referenceId,
};
