import 'package:app_movil_sistema/features/category/data/models/category_create_request_model.dart';
import 'package:app_movil_sistema/features/category/data/models/product_category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<ProductCategoryModel>> getCategories({String? search});

  Future<ProductCategoryModel> createCategory(
    CategoryCreateRequestModel request,
  );
}
