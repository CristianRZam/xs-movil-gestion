import 'package:app_movil_sistema/Reciclaje/text.dart';
import 'package:app_movil_sistema/core/failures/error_handler.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/core/validators/input_validators.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_bloc.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_event.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_state.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(const LoginSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.pushNamed(context, '/home',);
        } else if (state.status == LoginStatus.failure) {
          ErrorHandler.showFailure(
            context,
            errorCode: state.errorCode,
            message: state.errorMessage ?? 'Error desconocido',
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (p, c) => p.email != c.email,
              builder: (context, state) {
                return XsTextField(
                  labelText: "Correo electrónico",
                  prefixIcon: const Icon(Icons.email_outlined),
                  borderColor: AppColors.primary,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => composeValidators([
                    InputValidators.requiredField('Ingrese su correo'),
                    InputValidators.email(),
                  ], value),
                  onChanged: (value) =>
                      context.read<LoginBloc>().add(LoginEmailChanged(value)),
                  autoValidate: true,
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (p, c) => p.password != c.password,
              builder: (context, state) {
                return XsTextField(
                  labelText: "Contraseña",
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  borderColor: AppColors.primary,
                  validator: (value) => composeValidators([
                    InputValidators.requiredField('Ingrese su contraseña'),
                  ], value),
                  onChanged: (value) =>
                      context.read<LoginBloc>().add(LoginPasswordChanged(value)),
                  autoValidate: true,
                );
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                final isLoading = state.status == LoginStatus.loading;
                return XsButton(
                  text: isLoading ? 'Ingresando...' : 'Ingresar',
                  onPressed: isLoading ? () {}  : () => _submit(context),
                  mode: XsButtonMode.filled,
                  borderRadius: 12,
                );
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: AppColors.dark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
