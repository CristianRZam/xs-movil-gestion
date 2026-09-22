import 'package:app_movil_sistema/core/authorization/access_widgets.dart';
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/home/presentation/pages/home_screen.dart';
import 'package:app_movil_sistema/features/login/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';

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
    final token = await tokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      getIt<AccessControl>().updateToken(token);
      final bool isExpired = !getIt<AccessControl>().isAuthenticated;

      if (!isExpired) {
        _goTo(
          AccessGuard(
            capability: AppCapability.operate,
            builder: (_) => const HomeScreen(),
          ),
        );
        return;
      } else {
        await tokenStorage.deleteToken();
      }
    }

    _goTo(const LoginScreen());
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
