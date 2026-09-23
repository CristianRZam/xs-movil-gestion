import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_create_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';
import 'package:dartz/dartz.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<ProductCategory>>> getCategories({
    String? search,
  });

  Future<Either<Failure, ProductCategory>> createCategory(
    CategoryCreateRequest request,
  );
}
