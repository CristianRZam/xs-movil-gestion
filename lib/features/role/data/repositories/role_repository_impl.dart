import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/role/data/datasources/role_remote_datasource.dart';
import 'package:app_movil_sistema/features/role/domain/entities/role.dart';
import 'package:app_movil_sistema/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class RoleRepositoryImpl implements RoleRepository {
  RoleRepositoryImpl(this._remoteDataSource);
  final RoleRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<AppRole>>> getRoles() async {
    try {
      return Right(await _remoteDataSource.getRoles());
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, RolePermissions>> getRolePermissions(int roleId) async {
    try {
      return Right(await _remoteDataSource.getRolePermissions(roleId));
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateRolePermissions({
    required int roleId,
    required Set<int> permissionIds,
  }) async {
    try {
      await _remoteDataSource.updateRolePermissions(
        roleId: roleId,
        permissionIds: permissionIds,
      );
      return const Right(null);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
