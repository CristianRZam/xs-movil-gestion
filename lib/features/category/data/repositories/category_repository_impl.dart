import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/category/data/datasources/category_remote_datasource.dart';
import 'package:app_movil_sistema/features/category/data/models/category_create_request_model.dart';
import 'package:app_movil_sistema/features/category/data/models/category_update_request_model.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_create_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_update_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';
import 'package:app_movil_sistema/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remoteDataSource);
  final CategoryRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ProductCategory>>> getCategories({
    String? search,
  }) async {
    try {
      final categories = await _remoteDataSource.getCategories(search: search);
      final sorted = categories.map((category) => category.toEntity()).toList()
        ..sort((first, second) {
          final byOrder = first.orderNumber.compareTo(second.orderNumber);
          if (byOrder != 0) return byOrder;
          return first.parameterId.compareTo(second.parameterId);
        });
      return Right(sorted);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ProductCategory>> getCategoryForm(int id) async {
    try {
      final category = await _remoteDataSource.getCategoryForm(id);
      return Right(category.toEntity());
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ProductCategory>> createCategory(
    CategoryCreateRequest request,
  ) async {
    try {
      final category = await _remoteDataSource.createCategory(
        CategoryCreateRequestModel.fromEntity(request),
      );
      return Right(category.toEntity());
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ProductCategory>> updateCategory(
    CategoryUpdateRequest request,
  ) async {
    try {
      final category = await _remoteDataSource.updateCategory(
        CategoryUpdateRequestModel.fromEntity(request),
      );
      return Right(category.toEntity());
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
