import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/product_view_response.dart';
import '../repositories/product_repository.dart';
import '../entities/product_view_request.dart';

class GetProductViewUseCase {
  final ProductRepository repository;

  GetProductViewUseCase(this.repository);

  Future<Either<Failure, ProductViewResponse>> call(
    ProductViewRequest request,
  ) {
    return repository.getProductView(request);
  }
}
