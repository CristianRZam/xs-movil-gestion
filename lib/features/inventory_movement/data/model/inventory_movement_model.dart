import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/inventory_movement.dart';

part 'inventory_movement_model.g.dart';

@JsonSerializable()
class InventoryMovementModel extends InventoryMovement {

  const InventoryMovementModel({
    required super.id,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.previousStock,
    required super.currentStock,
    super.reason,
    super.referenceType,
    super.referenceId,
    required super.deleted,
  });

  factory InventoryMovementModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$InventoryMovementModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$InventoryMovementModelToJson(this);

  factory InventoryMovementModel.fromEntity(
      InventoryMovement entity,
      ) {
    return InventoryMovementModel(
      id: entity.id,
      productId: entity.productId,
      type: entity.type,
      quantity: entity.quantity,
      previousStock: entity.previousStock,
      currentStock: entity.currentStock,
      reason: entity.reason,
      referenceType: entity.referenceType,
      referenceId: entity.referenceId,
      deleted: entity.deleted,
    );
  }

  InventoryMovement toEntity() {
    return InventoryMovement(
      id: id,
      productId: productId,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      currentStock: currentStock,
      reason: reason,
      referenceType: referenceType,
      referenceId: referenceId,
      deleted: deleted,
    );
  }
}