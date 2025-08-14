import 'package:app_movil_sistema/features/login/domain/entities/auth_response.dart';
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final String email;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final int? errorCode;
  final AuthResponse? auth;

  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.errorCode,
    this.auth,
  });

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    int? errorCode,
    AuthResponse? auth,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      auth: auth ?? this.auth,
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage, errorCode, auth];
}
