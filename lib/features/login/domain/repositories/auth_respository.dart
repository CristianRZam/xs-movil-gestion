import 'package:dartz/dartz.dart';
import 'package:app_movil_sistema/core/failures/failure.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String email, String password);
}
