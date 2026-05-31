import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/core/theme/theme_cubit.dart';
import 'package:app_movil_sistema/features/login/domain/usecases/login_usecase.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_bloc.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_state.dart';
import 'package:app_movil_sistema/features/login/presentation/widgets/login_form.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(getIt<LoginUseCase>()),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          final isDark =
              Theme.of(context).brightness == Brightness.dark;

          return LoadingOverlay(
            isLoading: state.status == LoginStatus.loading,
            child: Scaffold(
              body: Stack(
                children: [
                  /// Fondo principal
                  Container(
                    color: isDark
                        ? AppColors.darkBody
                        : AppColors.secondary,
                  ),

                  /// Botón Dark / Light
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          top: 4,
                        ),
                        child: IconButton(
                          splashRadius: 24,
                          onPressed: () {
                            final themeCubit =
                            context.read<ThemeCubit>();

                            isDark
                                ? themeCubit.setLightTheme()
                                : themeCubit.setDarkTheme();
                          },
                          icon: Icon(
                            isDark
                                ? Icons.wb_sunny_rounded
                                : Icons.dark_mode_rounded,
                            size: 30,
                            color: isDark
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Contenido principal
                  SafeArea(
                    child: Column(
                      children: [
                        /// Logo
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Image.asset(
                              'assets/images/icono_sin_fondo.webp',
                              width: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        /// Panel inferior
                        Expanded(
                          flex: 5,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : AppColors.primary,
                              borderRadius:
                              const BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(
                                    0,
                                    -5,
                                  ),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 28,
                              ),
                              child: Column(
                                children: [
                                  const XsText(
                                    text: 'Iniciar Sesión',
                                    fontSize: 30,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors.white,
                                    textAlign:
                                    TextAlign.center,
                                  ),

                                  const SizedBox(
                                    height: 28,
                                  ),

                                  /// Card del formulario
                                  Card(
                                    elevation:
                                    isDark ? 2 : 10,
                                    shadowColor:
                                    Colors.black
                                        .withValues(
                                      alpha: 0.15,
                                    ),
                                    color: Theme.of(
                                        context)
                                        .cardColor,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        24,
                                      ),
                                    ),
                                    child: const Padding(
                                      padding:
                                      EdgeInsets.all(
                                        24,
                                      ),
                                      child: LoginForm(),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 24,
                                  ),

                                  Text(
                                    'Versión 1.0.0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}