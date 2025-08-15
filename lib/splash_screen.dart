import 'package:app_movil_sistema/features/home/presentation/pages/home_screen.dart';
import 'package:app_movil_sistema/features/login/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await tokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      final bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        _goTo(const HomeScreen());
        return;
      } else {
        await tokenStorage.deleteToken();
      }
    }

    _goTo(const LoginScreen());
  }

  void _goTo(Widget page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
