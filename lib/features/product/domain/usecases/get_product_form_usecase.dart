import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/product_form_request.dart';
import '../entities/product_form_response.dart';
import '../repositories/product_repository.dart';

class GetProductFormUseCase {
  final ProductRepository repository;

  GetProductFormUseCase(this.repository);

  Future<Either<Failure, ProductFormResponse>> call(
    ProductFormRequest request,
  ) {
    return repository.getProductForm(request);
  }
}
