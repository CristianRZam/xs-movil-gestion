import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/login/data/datasources/login_remote_datasource.dart';
import 'package:app_movil_sistema/features/login/domain/entities/auth_response.dart';
import 'package:app_movil_sistema/features/login/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LoginRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<Either<Failure, AuthResponse>> login(String email, String password) async {
    try {
      final model = await remoteDataSource.login(email, password);
      await tokenStorage.saveToken(model.token);
      return Right(model);
    } on DioException catch (dioError) {
      final failure = FailureMapper.fromDioException(dioError);
      return Left(failure);
    } catch (_) {
      return Left(UnexpectedFailure());
    }
  }
}
