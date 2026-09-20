import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_create_request.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_detail.dart';
import 'package:dartz/dartz.dart';

abstract class InventoryMovementRepository {

  Future<Either<Failure, List<InventoryMovementDetail>>> getInventoryMovements(int productId,);

  Future<Either<Failure, InventoryMovement>> createInventoryMovement(InventoryMovementCreateRequest request,);

}