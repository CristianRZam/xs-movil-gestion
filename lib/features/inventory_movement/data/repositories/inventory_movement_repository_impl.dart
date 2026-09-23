import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/datasources/inventory_movement_remote_datasource.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_create_request_model.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_create_request.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_page.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/repositories/inventory_movement_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class InventoryMovementRepositoryImpl implements InventoryMovementRepository {
  final InventoryMovementRemoteDataSource remoteDataSource;

  InventoryMovementRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, InventoryMovementPage>> getInventoryMovements(
    int productId, {
    required int page,
    required int size,
  }) async {
    try {
      final response = await remoteDataSource.getInventoryMovements(
        productId,
        page: page,
        size: size,
      );

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, InventoryMovement>> createInventoryMovement(
    InventoryMovementCreateRequest request,
  ) async {
    try {
      final response = await remoteDataSource.createInventoryMovement(
        InventoryMovementCreateRequestModel.fromEntity(request),
      );

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
