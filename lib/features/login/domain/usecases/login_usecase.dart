import 'package:app_movil_sistema/features/login/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/failures/failure.dart';

import '../entities/auth_response.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(String email, String password,) {
    return repository.login(email, password,);
  }
}