import 'package:app_movil_sistema/core/authorization/access_widgets.dart';
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/pages/cash_session_screen.dart';
import 'package:app_movil_sistema/features/home/presentation/pages/home_screen.dart';
import 'package:app_movil_sistema/features/login/presentation/pages/login_screen.dart';
import 'package:app_movil_sistema/features/product/presentation/pages/product_screen.dart';
import 'package:app_movil_sistema/features/order/presentation/pages/order_screen.dart';
import 'package:app_movil_sistema/features/sale/presentation/pages/sale_screen.dart';
import 'package:app_movil_sistema/features/report/presentation/pages/report_screen.dart';
import 'package:app_movil_sistema/features/profile/presentation/pages/profile_screen.dart';
import 'package:app_movil_sistema/features/inventory_count/presentation/pages/inventory_count_screen.dart';
import 'package:app_movil_sistema/features/notification/presentation/pages/notification_screen.dart';
import 'package:app_movil_sistema/features/category/presentation/pages/category_screen.dart';
import 'package:app_movil_sistema/features/user/presentation/pages/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/features/settings/presentation/pages/settings_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const product = '/product';
  static const cashSession = '/cash-session';
  static const orders = '/orders';
  static const sales = '/sales';
  static const reports = '/reports';
  static const profile = '/profile';
  static const settings = '/settings';
  static const inventoryCount = '/inventory-count';
  static const notifications = '/notifications';
  static const categories = '/categories';
  static const users = '/users';

  static final routes = <String, WidgetBuilder>{
    login: (context) => LoginScreen(),
    home: (context) => AccessGuard(
      capability: AppCapability.operate,
      builder: (_) => HomeScreen(),
    ),
    product: (context) => AccessGuard(
      capability: AppCapability.operate,
      builder: (_) => ProductScreen(),
    ),
    cashSession: (context) => AccessGuard(
      capability: AppCapability.operate,
      builder: (_) => CashSessionScreen(),
    ),
    orders: (context) => AccessGuard(
      capability: AppCapability.operate,
      builder: (_) => const OrderScreen(),
    ),
    sales: (context) => AccessGuard(
      capability: AppCapability.operate,
      builder: (_) => const SaleScreen(),
    ),
    reports: (context) => AccessGuard(
      capability: AppCapability.reports,
      builder: (_) => const ReportScreen(),
    ),
    profile: (context) => AccessGuard(
      capability: AppCapability.operate,
      builder: (_) => const ProfileScreen(),
    ),
    inventoryCount: (context) => AccessGuard(
      capability: AppCapability.inventoryCount,
      builder: (_) => const InventoryCountScreen(),
    ),
    notifications: (context) => AccessGuard(
      capability: AppCapability.notifications,
      builder: (_) => const NotificationScreen(),
    ),
    settings: (context) => AccessGuard(
      capability: AppCapability.operate,
      builder: (_) => const SettingsScreen(),
    ),
    categories: (context) => AccessGuard(
      capability: AppCapability.manageCategories,
      builder: (_) => const CategoryScreen(),
    ),
    users: (context) => AccessGuard(
      capability: AppCapability.manageUsers,
      builder: (_) => const UserScreen(),
    ),
  };
}
