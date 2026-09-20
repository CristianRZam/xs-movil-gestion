import 'package:app_movil_sistema/features/product/data/models/product_form_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_form_response_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_request_model.dart';

import '../models/product_view_request_model.dart';
import '../models/product_view_response_model.dart';


abstract class ProductRemoteDataSource {

  Future<ProductViewResponseModel> getProductView(ProductViewRequestModel request,);

  Future<ProductFormResponseModel> getProductForm(ProductFormRequestModel request,);

  Future<ProductModel> createProduct(ProductRequestModel request,);

  Future<ProductModel> updateProduct(ProductRequestModel request,);

  Future<bool> deleteProduct(int id);

}

