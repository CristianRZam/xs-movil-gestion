import 'package:app_movil_sistema/core/theme/theme_notifier.dart';
import 'package:app_movil_sistema/features/login/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Simulador Yape',
          style: TextStyle(color: Colors.deepPurple),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Row(
            children: [
              Icon(
                themeNotifier.isDark ? Icons.dark_mode : Icons.light_mode,
                color: Colors.deepPurple,
              ),
              Switch(
                value: themeNotifier.isDark,
                activeColor: Colors.deepPurple,
                onChanged: (value) {
                  themeNotifier.setDarkMode(value);
                },
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            children: const [
              SizedBox(height: 32),
              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Ingresa tus credenciales para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 32),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
