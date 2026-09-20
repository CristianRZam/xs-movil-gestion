import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.deleteProduct(id);
  }
}