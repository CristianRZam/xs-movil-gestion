import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failures/failure.dart';
import '../../../../core/failures/failure_mapper.dart';
import '../../../../core/storage/token_storage.dart';

import '../../domain/entities/auth_response.dart';

import '../../domain/repositories/auth_respository.dart';
import '../datasources/login_remote_datasource.dart';

class AuthRepositoryImpl
    implements AuthRepository {
  final LoginRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage,);

  @override
  Future<Either<Failure, AuthResponse>> login(String email,String password,) async {
    try {
      final auth = await remoteDataSource.login(email,password,);

      await tokenStorage.saveToken(auth.token,);

      return Right(auth);
    } on DioException catch (e) {
      return Left(FailureMapper.fromDioException(e),);
    } catch (_) {
      return Left(UnexpectedFailure(),);
    }
  }
}