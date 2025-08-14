import 'package:flutter/material.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';

class ErrorHandler {
  static void showFailure(
      BuildContext context, {
        required int? errorCode,
        required String message,
      }) {
    String title = _getTitleForCode(errorCode);

    FlashMessage.show(
      context,
      type: FlashMessageType.error,
      title: title,
      message: message,
      position: errorCode == -1 ? FlashMessagePosition.center : FlashMessagePosition.bottom,
    );
  }

  static String _getTitleForCode(int? code) {
    if (code == null) return "Error inesperado";

    switch (code) {
      case 1001:
        return "Error de inicio de sesión";
      case 500:
        return "Error del servidor";
      case -1:
        return "Problema de conexión";
      default:
        return "Error inesperado";
    }
  }
}
