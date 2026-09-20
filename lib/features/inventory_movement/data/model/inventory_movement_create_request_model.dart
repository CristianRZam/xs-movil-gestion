import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/inventory_movement_create_request.dart';

part 'inventory_movement_create_request_model.g.dart';

@JsonSerializable()
class InventoryMovementCreateRequestModel
    extends InventoryMovementCreateRequest {

  const InventoryMovementCreateRequestModel({
    required super.productId,
    required super.type,
    required super.quantity,
    required super.previousStock,
    required super.currentStock,
    super.reason,
    super.referenceType,
    super.referenceId,
  });

  factory InventoryMovementCreateRequestModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$InventoryMovementCreateRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$InventoryMovementCreateRequestModelToJson(this);

  factory InventoryMovementCreateRequestModel.fromEntity(
      InventoryMovementCreateRequest entity,
      ) {
    return InventoryMovementCreateRequestModel(
      productId: entity.productId,
      type: entity.type,
      quantity: entity.quantity,
      previousStock: entity.previousStock,
      currentStock: entity.currentStock,
      reason: entity.reason,
      referenceType: entity.referenceType,
      referenceId: entity.referenceId,
    );
  }

  InventoryMovementCreateRequest toEntity() {
    return InventoryMovementCreateRequest(
      productId: productId,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      currentStock: currentStock,
      reason: reason,
      referenceType: referenceType,
      referenceId: referenceId,
    );
  }
}