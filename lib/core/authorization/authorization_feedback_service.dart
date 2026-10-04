import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:flutter/widgets.dart';

/// Shows one consistent message when the API rejects a previously available
/// action because the user's permissions changed during an active session.
class AuthorizationFeedbackService {
  AuthorizationFeedbackService(this._sessionCoordinator);

  final SessionCoordinator _sessionCoordinator;
  DateTime? _lastShownAt;

  void showUnauthorizedAction() {
    final now = DateTime.now();
    if (_lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastShownAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _sessionCoordinator.navigatorKey.currentState;
      final overlay = navigator?.overlay;
      final context = navigator?.context;
      if (overlay == null || context == null) return;
      FlashMessage.showOnOverlay(
        overlay,
        context: context,
        type: FlashMessageType.warning,
        title: 'Acción no autorizada',
        message:
            'No tienes permiso para realizar esta acción. Tus permisos pueden haber sido actualizados.',
        position: FlashMessagePosition.top,
      );
    });
  }
}
