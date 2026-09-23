import 'package:flutter/material.dart';
import 'app_colors.dart';

class PaymentMethodStyle {
  static Color color(String method) => switch (method.toUpperCase()) {
    'YAPE' => AppColors.yapePrimary,
    'PLIN' => AppColors.plinPrimary,
    'CASH' => Colors.green,
    'CARD' => Colors.blue,
    'TRANSFER' => Colors.teal,
    _ => AppColors.grey,
  };

  static IconData icon(String method) => switch (method.toUpperCase()) {
    'YAPE' || 'PLIN' => Icons.account_balance_wallet_rounded,
    'CASH' => Icons.payments_rounded,
    'CARD' => Icons.credit_card_rounded,
    'TRANSFER' => Icons.account_balance_rounded,
    _ => Icons.payments_outlined,
  };
}
