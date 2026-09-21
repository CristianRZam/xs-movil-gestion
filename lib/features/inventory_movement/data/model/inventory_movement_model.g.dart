// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryMovementModel _$InventoryMovementModelFromJson(
  Map<String, dynamic> json,
) => InventoryMovementModel(
  id: (json['id'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  type: json['type'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  previousStock: (json['previousStock'] as num).toDouble(),
  currentStock: (json['currentStock'] as num).toDouble(),
  reason: json['reason'] as String?,
  referenceType: json['referenceType'] as String?,
  referenceId: (json['referenceId'] as num?)?.toInt(),
  deleted: json['deleted'] as bool,
);

Map<String, dynamic> _$InventoryMovementModelToJson(
  InventoryMovementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'type': instance.type,
  'quantity': instance.quantity,
  'previousStock': instance.previousStock,
  'currentStock': instance.currentStock,
  'reason': instance.reason,
  'referenceType': instance.referenceType,
  'referenceId': instance.referenceId,
  'deleted': instance.deleted,
};
