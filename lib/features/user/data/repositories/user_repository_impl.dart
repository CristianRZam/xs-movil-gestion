import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';
import 'package:app_movil_sistema/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);
  final UserRemoteDataSource _remote;
  @override
  Future<Either<Failure, List<AppUser>>> getUsers(UserFilter f) async {
    try {
      final data = await _remote.getUsers(f);
      return Right(data.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserFormData>> getFormData([int? id]) async {
    try {
      return Right((await _remote.getFormData(id)).toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> create(UserRequest r) async {
    try {
      return Right((await _remote.create(r)).toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> update(UserRequest r) async {
    try {
      return Right((await _remote.update(r)).toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus(int id) async {
    try {
      await _remote.updateStatus(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
