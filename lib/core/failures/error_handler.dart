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
      position: errorCode == -1 ? FlashMessagePosition.center : FlashMessagePosition.top,
    );
  }

  static String _getTitleForCode(int? code) {
    switch (code) {
      case -1:
        return 'Problema de conexión';

      case 400:
        return 'Solicitud inválida';

      case 401:
        return 'No autorizado';

      case 403:
        return 'Acceso denegado';

      case 404:
        return 'Recurso no encontrado';

      case 408:
        return 'Tiempo de espera agotado';

      case 409:
        return 'Conflicto de información';

      case 422:
        return 'Error de validación';

      case 429:
        return 'Demasiadas solicitudes';

      case 500:
        return 'Error interno del servidor';

      case 502:
        return 'Error de servicio';

      case 503:
        return 'Servicio no disponible';

      case 504:
        return 'Tiempo de respuesta agotado';

      default:
        return 'Error inesperado';
    }
  }
}
