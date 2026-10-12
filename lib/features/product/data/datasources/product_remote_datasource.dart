import 'package:app_movil_sistema/features/product/data/models/product_form_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_form_response_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_save_request_model.dart';

import '../models/product_view_request_model.dart';
import '../models/product_view_response_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductViewResponseModel> getProductView(
    ProductViewRequestModel request,
  );

  Future<ProductFormResponseModel> getProductForm(
    ProductFormRequestModel request,
  );

  Future<ProductModel> createProduct(ProductSaveRequestModel request);

  Future<ProductModel> updateProduct(ProductSaveRequestModel request);

  Future<bool> deleteProduct(int id);

  Future<bool> updateProductStatus(int id);
}
