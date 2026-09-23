import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/inventory_movement_detail.dart';

part 'inventory_movement_detail_model.g.dart';

@JsonSerializable()
class InventoryMovementDetailModel extends InventoryMovementDetail {
  const InventoryMovementDetailModel({
    required super.id,
    required super.type,
    required super.quantity,
    required super.previousStock,
    required super.currentStock,
    super.reason,
    super.referenceType,
    super.referenceId,
    required super.deleted,

    required super.productId,
    required super.productCode,
    required super.productName,

    required super.createdAt,
    required super.createdBy,

    super.modifiedAt,
    super.modifiedBy,

    super.deletedAt,
    super.deletedBy,
  });

  factory InventoryMovementDetailModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryMovementDetailModelToJson(this);

  factory InventoryMovementDetailModel.fromEntity(
    InventoryMovementDetail entity,
  ) {
    return InventoryMovementDetailModel(
      id: entity.id,
      type: entity.type,
      quantity: entity.quantity,
      previousStock: entity.previousStock,
      currentStock: entity.currentStock,
      reason: entity.reason,
      referenceType: entity.referenceType,
      referenceId: entity.referenceId,
      deleted: entity.deleted,
      productId: entity.productId,
      productCode: entity.productCode,
      productName: entity.productName,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      modifiedAt: entity.modifiedAt,
      modifiedBy: entity.modifiedBy,
      deletedAt: entity.deletedAt,
      deletedBy: entity.deletedBy,
    );
  }

  InventoryMovementDetail toEntity() {
    return InventoryMovementDetail(
      id: id,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      currentStock: currentStock,
      reason: reason,
      referenceType: referenceType,
      referenceId: referenceId,
      deleted: deleted,
      productId: productId,
      productCode: productCode,
      productName: productName,
      createdAt: createdAt,
      createdBy: createdBy,
      modifiedAt: modifiedAt,
      modifiedBy: modifiedBy,
      deletedAt: deletedAt,
      deletedBy: deletedBy,
    );
  }
}
