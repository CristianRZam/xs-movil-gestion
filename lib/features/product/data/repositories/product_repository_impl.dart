import 'package:app_movil_sistema/features/product/data/models/product_form_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_request_model.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_request.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_response.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_request.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failures/failure.dart';
import '../../../../core/failures/failure_mapper.dart';

import '../../domain/entities/product_view_request.dart';
import '../../domain/entities/product_view_response.dart';
import '../../domain/repositories/product_repository.dart';

import '../datasources/product_remote_datasource.dart';
import '../models/product_view_request_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProductViewResponse>> getProductView(
    ProductViewRequest request,
  ) async {
    try {
      final response = await remoteDataSource.getProductView(
        ProductViewRequestModel.fromEntity(request),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ProductFormResponse>> getProductForm(
    ProductFormRequest request,
  ) async {
    try {
      final response = await remoteDataSource.getProductForm(
        ProductFormRequestModel.fromEntity(request),
      );

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(ProductRequest request) async {
    try {
      final response = await remoteDataSource.createProduct(
        ProductRequestModel.fromEntity(request),
      );

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(ProductRequest request) async {
    try {
      final response = await remoteDataSource.updateProduct(
        ProductRequestModel.fromEntity(request),
      );

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(int id) async {
    try {
      final response = await remoteDataSource.deleteProduct(id);

      return Right(response);
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateProductStatus(int id) async {
    try {
      return Right(await remoteDataSource.updateProductStatus(id));
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
