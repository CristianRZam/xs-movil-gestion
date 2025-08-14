import 'package:dartz/dartz.dart';
import 'package:app_movil_sistema/core/failures/failure.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_respository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(String email, String password) {
    return repository.login(email, password);
  }
}
