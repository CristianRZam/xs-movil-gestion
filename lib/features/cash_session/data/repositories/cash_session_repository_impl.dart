import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/failures/failure_mapper.dart';
import 'package:app_movil_sistema/features/cash_session/data/datasources/cash_session_remote_datasource.dart';
import 'package:app_movil_sistema/features/cash_session/data/models/cash_session_close_request_model.dart';
import 'package:app_movil_sistema/features/cash_session/data/models/cash_session_model.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session_close_request.dart';
import 'package:app_movil_sistema/features/cash_session/domain/repositories/cash_session_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CashSessionRepositoryImpl implements CashSessionRepository {

  final CashSessionRemoteDataSource remoteDataSource;

  CashSessionRepositoryImpl(this.remoteDataSource,);


  @override
  Future<Either<Failure, CashSession>> openSession(CashSession request,) async {
    try {
      final response = await remoteDataSource.openSession(
        CashSessionModel.fromEntity(request),
      );

      return Right(
        response.toEntity(),
      );

    } on DioException catch (e) {

      return Left(
        FailureMapper.fromDioException(e),
      );

    } catch (_) {

      return Left(
        UnexpectedFailure(),
      );

    }
  }


  @override
  Future<Either<Failure, CashSession>> getCurrentSession() async {
    try {
      final response = await remoteDataSource.getCurrentSession();

      return Right(
        response.toEntity(),
      );

    } on DioException catch (e) {

      return Left(
        FailureMapper.fromDioException(e),
      );

    } catch (_) {

      return Left(
        UnexpectedFailure(),
      );

    }
  }


  @override
  Future<Either<Failure, bool>> existsOpenSession() async {
    try {
      final response = await remoteDataSource.existsOpenSession();

      return Right(
        response,
      );

    } on DioException catch (e) {

      return Left(
        FailureMapper.fromDioException(e),
      );

    } catch (_) {

      return Left(
        UnexpectedFailure(),
      );

    }
  }


  @override
  Future<Either<Failure, CashSession>> closeSession(CashSessionCloseRequest request,) async {
    try {
      final response = await remoteDataSource.closeSession(
        CashSessionCloseRequestModel.fromEntity(request),
      );

      return Right(
        response.toEntity(),
      );

    } on DioException catch (e) {

      return Left(
        FailureMapper.fromDioException(e),
      );

    } catch (_) {

      return Left(
        UnexpectedFailure(),
      );

    }
  }


  @override
  Future<Either<Failure, List<CashSession>>> getHistory() async {
    try {
      final response = await remoteDataSource.getHistory();

      return Right(
        response.map((item) => item.toEntity(),).toList(),
      );

    } on DioException catch (e) {

      return Left(
        FailureMapper.fromDioException(e),
      );

    } catch (_) {

      return Left(
        UnexpectedFailure(),
      );

    }
  }
}