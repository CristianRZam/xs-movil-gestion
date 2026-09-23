import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateProductStatusUseCase {
  const UpdateProductStatusUseCase(this._repository);
  final ProductRepository _repository;
  Future<Either<Failure, bool>> call(int productId) =>
      _repository.updateProductStatus(productId);
}
