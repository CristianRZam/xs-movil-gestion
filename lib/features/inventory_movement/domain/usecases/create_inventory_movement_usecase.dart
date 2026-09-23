import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/inventory_movement.dart';
import '../entities/inventory_movement_create_request.dart';
import '../repositories/inventory_movement_repository.dart';

class CreateInventoryMovementUseCase {
  final InventoryMovementRepository repository;

  CreateInventoryMovementUseCase(this.repository);

  Future<Either<Failure, InventoryMovement>> call(
    InventoryMovementCreateRequest request,
  ) {
    return repository.createInventoryMovement(request);
  }
}
