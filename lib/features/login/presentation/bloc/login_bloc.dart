import 'package:app_movil_sistema/features/login/domain/usecases/login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase) : super(const LoginState()) {
    on<LoginEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });

    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });

    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));
    final result = await loginUseCase(state.email, state.password);

    result.fold(
          (failure) => emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message ?? 'Error desconocido',
        errorCode: failure.code,

      )),
          (auth) => emit(state.copyWith(
        status: LoginStatus.success,
        auth: auth,
      )),
    );
  }

}
