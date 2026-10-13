import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/core/theme/theme_cubit.dart';
import 'package:app_movil_sistema/features/login/domain/usecases/login_usecase.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_bloc.dart';
import 'package:app_movil_sistema/features/login/presentation/bloc/login_state.dart';
import 'package:app_movil_sistema/features/login/presentation/widgets/login_form.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => LoginBloc(getIt<LoginUseCase>()),
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final surface = isDark ? const Color(0xFF171717) : Colors.white;
            final mutedText = isDark ? Colors.white60 : const Color(0xFF6F5B5A);
            final lowerSurface = Color.alphaBlend(
              AppColors.primary.withValues(alpha: isDark ? .08 : .018),
              surface,
            );

            return LoadingOverlay(
              isLoading: state.status == LoginStatus.loading,
              child: Scaffold(
                backgroundColor: surface,
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.primary, Color(0xFF72080E)],
                                ),
                              ),
                            ),
                            Positioned(
                              right: -48,
                              top: -64,
                              child: _DecorativeCircle(
                                size: 190,
                                color: Colors.white.withValues(alpha: .08),
                              ),
                            ),
                            Positioned(
                              left: -35,
                              bottom: -55,
                              child: _DecorativeCircle(
                                size: 146,
                                color: Colors.white.withValues(alpha: .06),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  right: 14,
                                ),
                                child: _ThemeButton(
                                  isDark: isDark,
                                  onPressed: () {
                                    final cubit = context.read<ThemeCubit>();
                                    isDark
                                        ? cubit.setLightTheme()
                                        : cubit.setDarkTheme();
                                  },
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(42, 40, 42, 20),
                                child: Image.asset(
                                  'assets/images/main_logo.png',
                                  width: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Container(
                          width: double.infinity,
                          transform: Matrix4.translationValues(0, -22, 0),
                          // El panel ocupa todo el ancho. El relleno se aplica
                          // solamente al contenido, para que las burbujas lleguen
                          // visualmente de borde a borde también en modo oscuro.
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: lowerSurface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .14),
                                blurRadius: 22,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              // Decoración sutil: usa el color primario activo.
                              Positioned(
                                right: -72,
                                top: 42,
                                child: _DecorativeCircle(
                                  size: 176,
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? .10 : .06,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -56,
                                bottom: -50,
                                child: _DecorativeCircle(
                                  size: 152,
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? .085 : .052,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 42,
                                bottom: 52,
                                child: _DecorativeCircle(
                                  size: 48,
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? .075 : .045,
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(28, 32, 28, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Bienvenido de nuevo',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF281718),
                                      ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Ingresa tus credenciales para continuar.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: mutedText),
                                ),
                                const SizedBox(height: 26),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: .045)
                                        : const Color(0xFFFFF8F8),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: isDark ? .25 : .12,
                                      ),
                                    ),
                                  ),
                                  child: const LoginForm(),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Versión 1.0.0',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: mutedText),
                                ),
                              ],
                            ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.isDark, required this.onPressed});

  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .14),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: isDark ? 'Usar tema claro' : 'Usar tema oscuro',
          onPressed: onPressed,
          icon: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
            color: Colors.white,
            size: 21,
          ),
        ),
      );
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
