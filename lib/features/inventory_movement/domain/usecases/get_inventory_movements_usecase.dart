import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/inventory_movement_detail.dart';
import '../repositories/inventory_movement_repository.dart';

class GetInventoryMovementsUseCase {

  final InventoryMovementRepository repository;

  GetInventoryMovementsUseCase(this.repository);

  Future<Either<Failure, List<InventoryMovementDetail>>> call(int productId,) {
    return repository.getInventoryMovements(productId);
  }

}