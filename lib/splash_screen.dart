import 'package:app_movil_sistema/core/authorization/access_widgets.dart';
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/home/presentation/pages/home_screen.dart';
import 'package:app_movil_sistema/features/login/presentation/pages/login_screen.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:app_movil_sistema/core/app_version/app_version_service.dart';
import 'package:app_movil_sistema/core/app_version/app_update_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final tokenStorage = getIt<TokenStorage>();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final version = await getIt<AppVersionService>().check();
      final continuePage = await _resolveStartPage();
      if (version.updateAvailable || version.updateRequired) {
        _goTo(AppUpdateScreen(status: version, continuePage: continuePage));
        return;
      }
      _goTo(continuePage);
    } catch (_) {
      _goTo(const _VersionCheckUnavailableScreen());
    }
  }

  Future<Widget> _resolveStartPage() async {
    final token = await tokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      getIt<AccessControl>().updateToken(token);
      final bool isExpired = !getIt<AccessControl>().isAuthenticated;

      if (!isExpired) {
        return AccessGuard(
          capability: AppCapability.operate,
          builder: (_) => const HomeScreen(),
        );
      } else {
        await tokenStorage.deleteToken();
      }
    }
    return const LoginScreen();
  }

  void _goTo(Widget page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Image.asset(
              'assets/images/main_logo.png',
              fit: BoxFit.contain,
              semanticLabel: 'Dulce Primavera Pastelería Fina',
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionCheckUnavailableScreen extends StatelessWidget {
  const _VersionCheckUnavailableScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Text(
              'No se pudo verificar la versión de la aplicación. Conéctese a internet y vuelva a intentarlo.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}
