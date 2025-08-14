import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/login/data/datasources/login_remote_datasource.dart';
import 'package:app_movil_sistema/features/login/domain/entities/auth_response.dart';
import 'package:app_movil_sistema/features/login/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LoginRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthResponse>> login(String email, String password) async {
    try {
      final model = await remoteDataSource.login(email, password);
      return Right(model);
    } on DioException catch (dioError) {
      final failure = FailureMapper.fromDioException(dioError);
      return Left(failure);
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
