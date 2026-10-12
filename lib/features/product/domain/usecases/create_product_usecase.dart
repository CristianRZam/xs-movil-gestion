import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/product.dart';
import '../entities/product_save_request.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(ProductSaveRequest request) {
    return repository.createProduct(request);
  }
}
