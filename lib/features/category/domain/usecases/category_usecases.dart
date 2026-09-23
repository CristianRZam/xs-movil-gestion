import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_create_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';
import 'package:app_movil_sistema/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);
  final CategoryRepository _repository;

  Future<Either<Failure, List<ProductCategory>>> call({String? search}) =>
      _repository.getCategories(search: search);
}

class CreateCategoryUseCase {
  CreateCategoryUseCase(this._repository);
  final CategoryRepository _repository;

  Future<Either<Failure, ProductCategory>> call(
    CategoryCreateRequest request,
  ) => _repository.createCategory(request);
}
