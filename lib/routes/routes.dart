import 'package:app_movil_sistema/features/home/presentation/pages/home_screen.dart';
import 'package:app_movil_sistema/features/login/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';

  static final routes = <String, WidgetBuilder>{
    login: (context) => LoginScreen(),
    home: (context) => HomeScreen(),
  };
}
