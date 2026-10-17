import 'dart:async';

import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:flutter/widgets.dart';

/// Agenda avisos de vencimiento sin depender de la pantalla abierta.
///
/// Los temporizadores solo existen mientras la aplicación está en primer
/// plano. Al volver desde segundo plano se vuelven a calcular con el `exp`
/// real del JWT, sin mostrar avisos atrasados ni duplicados.
class SessionExpiryWarningService with WidgetsBindingObserver {
  SessionExpiryWarningService(this._access, this._sessionCoordinator);

  static const _warningMinutes = <int>[5, 2, 1];

  final AccessControl _access;
  final SessionCoordinator _sessionCoordinator;
  final Set<int> _shownWarnings = <int>{};

  Timer? _nextWarningTimer;
  DateTime? _trackedExpiry;
  bool _started = false;
  bool _isActive = true;

  void start() {
    if (_started) return;
    _started = true;
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _isActive = lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _access.addListener(_onSessionChanged);
    WidgetsBinding.instance.addObserver(this);
    _synchronize();
  }

  void _onSessionChanged() {
    final expiry = _access.expiresAt;
    if (expiry != _trackedExpiry) {
      _trackedExpiry = expiry;
      _shownWarnings.clear();
    }
    _synchronize();
  }

  void _synchronize() {
    _nextWarningTimer?.cancel();
    _nextWarningTimer = null;

    final expiry = _access.expiresAt;
    if (!_isActive || !_access.isAuthenticated || expiry == null) return;

    final now = DateTime.now();
    for (final minutes in _warningMinutes) {
      final dueAt = expiry.subtract(Duration(minutes: minutes));
      if (!_shownWarnings.contains(minutes) && dueAt.isAfter(now)) {
        _nextWarningTimer = Timer(dueAt.difference(now), () {
          if (!_canNotifyFor(expiry)) return;
          _shownWarnings.add(minutes);
          _showWarning(minutes);
          _synchronize();
        });
        break;
      }
    }
  }

  bool _canNotifyFor(DateTime expiry) =>
      _isActive && _access.isAuthenticated && _access.expiresAt == expiry;

  void _showWarning(int minutes) {
    final message = switch (minutes) {
      5 => 'Tu sesión cerrará en 5 minutos. Guarda tu trabajo.',
      2 => 'Tu sesión cerrará en 2 minutos. Guarda tu trabajo.',
      _ => 'Tu sesión cerrará en 1 minuto. Guarda tu trabajo.',
    };
    _show(
      type: minutes == 1 ? FlashMessageType.error : FlashMessageType.warning,
      title: 'Sesión por vencer',
      message: message,
    );
  }

  void _show({
    required FlashMessageType type,
    required String title,
    required String message,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isActive || !_access.isAuthenticated) return;
      final navigator = _sessionCoordinator.navigatorKey.currentState;
      final overlay = navigator?.overlay;
      final context = navigator?.context;
      if (overlay == null || context == null || !overlay.mounted) return;
      FlashMessage.showOnOverlay(
        overlay,
        context: context,
        type: type,
        title: title,
        message: message,
        position: FlashMessagePosition.top,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isActive = state == AppLifecycleState.resumed;
    _synchronize();
  }

  void dispose() {
    _nextWarningTimer?.cancel();
    _access.removeListener(_onSessionChanged);
    WidgetsBinding.instance.removeObserver(this);
  }
}
