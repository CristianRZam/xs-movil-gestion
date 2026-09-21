import 'package:app_movil_sistema/features/cash_session/presentation/pages/cash_session_screen.dart';
import 'package:app_movil_sistema/features/home/presentation/pages/home_screen.dart';
import 'package:app_movil_sistema/features/login/presentation/pages/login_screen.dart';
import 'package:app_movil_sistema/features/product/presentation/pages/product_screen.dart';
import 'package:app_movil_sistema/features/order/presentation/pages/order_screen.dart';
import 'package:app_movil_sistema/features/sale/presentation/pages/sale_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const product = '/product';
  static const cashSession = '/cash-session';
  static const orders = '/orders';
  static const sales = '/sales';

  static final routes = <String, WidgetBuilder>{
    login: (context) => LoginScreen(),
    home: (context) => HomeScreen(),
    product: (context) => ProductScreen(),
    cashSession: (context) => CashSessionScreen(),
    orders: (context) => const OrderScreen(),
    sales: (context) => const SaleScreen(),

  };
}
