import 'package:app_movil_sistema/features/login/data/datasources/login_remote_datasource.dart';
import 'package:app_movil_sistema/features/login/data/repositories/auth_repository_impl.dart';
import 'package:app_movil_sistema/features/login/domain/usecases/login_usecase.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_bloc.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_state.dart';
import 'package:app_movil_sistema/features/login/presentation/widgets/login_form.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_movil_sistema/core/theme/theme_cubit.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-text.dart';
import 'package:app_movil_sistema/core/network/api_client.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        LoginUseCase(
          AuthRepositoryImpl(
            LoginRemoteDataSourceImpl(ApiClient()),
          ),
        ),
      ),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.status == LoginStatus.loading,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Switch(
                              value: Theme.of(context).brightness == Brightness.dark,
                              activeColor: Theme.of(context).colorScheme.primary,
                              onChanged: (value) {
                                final themeCubit = context.read<ThemeCubit>();
                                value ? themeCubit.setDarkTheme() : themeCubit.setLightTheme();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const XsText(
                        text: '¡Bienvenido!',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                        useDarkModeColor: true,
                      ),
                      const SizedBox(height: 10),
                      const XsText(
                        text: 'Ingresa tus credenciales para continuar',
                        fontSize: 16,
                        textAlign: TextAlign.center,
                        color: AppColors.dark,
                        useDarkModeColor: true,
                      ),
                      const SizedBox(height: 32),
                      const LoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
