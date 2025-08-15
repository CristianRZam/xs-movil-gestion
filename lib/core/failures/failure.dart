abstract class Failure {
  final String message;
  final int? code;
  Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  ServerFailure(super.message, {super.code});
}

class TimeoutFailure extends Failure {
  TimeoutFailure({int? code}) : super('Tiempo de espera agotado', code: code);
}

class NetworkFailure extends Failure {
  NetworkFailure({int? code}) : super('No hay conexión a internet', code: -1);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({int? code}) : super('Error inesperado', code: code);
}

class AuthFailure extends Failure {
  AuthFailure(super.message, {super.code});
}
