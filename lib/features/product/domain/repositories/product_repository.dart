import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_request.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_response.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_request.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';
import '../entities/product_view_response.dart';

abstract class ProductRepository {

  Future<Either<Failure, ProductViewResponse>> getProductView( ProductViewRequest request,);

  Future<Either<Failure, ProductFormResponse>> getProductForm(ProductFormRequest request,);

  Future<Either<Failure, Product>> createProduct(ProductRequest request,);

  Future<Either<Failure, Product>> updateProduct(ProductRequest request,);

  Future<Either<Failure, bool>> deleteProduct(int id);

}