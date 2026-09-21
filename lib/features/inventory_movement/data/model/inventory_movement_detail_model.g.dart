// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryMovementDetailModel _$InventoryMovementDetailModelFromJson(
  Map<String, dynamic> json,
) => InventoryMovementDetailModel(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  previousStock: (json['previousStock'] as num).toDouble(),
  currentStock: (json['currentStock'] as num).toDouble(),
  reason: json['reason'] as String?,
  referenceType: json['referenceType'] as String?,
  referenceId: (json['referenceId'] as num?)?.toInt(),
  deleted: json['deleted'] as bool,
  productId: (json['productId'] as num).toInt(),
  productCode: json['productCode'] as String,
  productName: json['productName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  createdBy: json['createdBy'] as String,
  modifiedAt: json['modifiedAt'] == null
      ? null
      : DateTime.parse(json['modifiedAt'] as String),
  modifiedBy: json['modifiedBy'] as String?,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  deletedBy: json['deletedBy'] as String?,
);

Map<String, dynamic> _$InventoryMovementDetailModelToJson(
  InventoryMovementDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'quantity': instance.quantity,
  'previousStock': instance.previousStock,
  'currentStock': instance.currentStock,
  'reason': instance.reason,
  'referenceType': instance.referenceType,
  'referenceId': instance.referenceId,
  'deleted': instance.deleted,
  'productId': instance.productId,
  'productCode': instance.productCode,
  'productName': instance.productName,
  'createdAt': instance.createdAt.toIso8601String(),
  'createdBy': instance.createdBy,
  'modifiedAt': instance.modifiedAt?.toIso8601String(),
  'modifiedBy': instance.modifiedBy,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'deletedBy': instance.deletedBy,
};
