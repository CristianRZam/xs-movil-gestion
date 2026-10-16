import 'package:app_movil_sistema/features/category/data/models/category_create_request_model.dart';
import 'package:app_movil_sistema/features/category/data/models/category_update_request_model.dart';
import 'package:app_movil_sistema/features/category/data/models/product_category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<ProductCategoryModel>> getCategories({String? search});

  Future<ProductCategoryModel> getCategoryForm(int id);

  Future<ProductCategoryModel> createCategory(
    CategoryCreateRequestModel request,
  );

  Future<ProductCategoryModel> updateCategory(
    CategoryUpdateRequestModel request,
  );
}
