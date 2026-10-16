import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_create_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_update_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';
import 'package:app_movil_sistema/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);
  final CategoryRepository _repository;

  Future<Either<Failure, List<ProductCategory>>> call({String? search}) =>
      _repository.getCategories(search: search);
}

class GetCategoryFormUseCase {
  GetCategoryFormUseCase(this._repository);
  final CategoryRepository _repository;

  Future<Either<Failure, ProductCategory>> call(int id) =>
      _repository.getCategoryForm(id);
}

class CreateCategoryUseCase {
  CreateCategoryUseCase(this._repository);
  final CategoryRepository _repository;

  Future<Either<Failure, ProductCategory>> call(
    CategoryCreateRequest request,
  ) => _repository.createCategory(request);
}

class UpdateCategoryUseCase {
  UpdateCategoryUseCase(this._repository);
  final CategoryRepository _repository;

  Future<Either<Failure, ProductCategory>> call(
    CategoryUpdateRequest request,
  ) => _repository.updateCategory(request);
}
