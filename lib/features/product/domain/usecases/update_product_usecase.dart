import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/product.dart';
import '../entities/product_request.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(ProductRequest request) {
    return repository.updateProduct(request);
  }
}
