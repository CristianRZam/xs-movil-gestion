import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_movil_sistema/features/profile/domain/entities/user_profile.dart';
import 'package:app_movil_sistema/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UserProfile>> getProfile() =>
      _handle(_remoteDataSource.getProfile);

  @override
  Future<Either<Failure, void>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmationPassword,
  }) => _handle(
    () => _remoteDataSource.updatePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmationPassword: confirmationPassword,
    ),
  );

  Future<Either<Failure, T>> _handle<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (error) {
      return Left(FailureMapper.fromDioException(error));
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
