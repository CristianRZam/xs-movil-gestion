import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/inventory_movement_page.dart';
import '../repositories/inventory_movement_repository.dart';

class GetInventoryMovementsUseCase {
  final InventoryMovementRepository repository;

  GetInventoryMovementsUseCase(this.repository);

  Future<Either<Failure, InventoryMovementPage>> call(
    int productId, {
    required int page,
    required int size,
  }) {
    return repository.getInventoryMovements(productId, page: page, size: size);
  }
}
