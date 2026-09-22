import 'dart:async';

import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:flutter/material.dart';

/// Coordinates session termination independently of the screen currently open.
class SessionCoordinator {
  SessionCoordinator(this._access, this._tokenStorage)
      : _wasAuthenticated = _access.isAuthenticated {
    _access.addListener(_onAccessChanged);
  }

  static const loginRoute = '/login';

  final AccessControl _access;
  final TokenStorage _tokenStorage;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _wasAuthenticated;
  bool _isEndingSession = false;
  bool _loginNavigationScheduled = false;

  void _onAccessChanged() {
    if (_access.isAuthenticated) {
      _wasAuthenticated = true;
      _loginNavigationScheduled = false;
      return;
    }

    if (!_wasAuthenticated || _isEndingSession) return;

    _wasAuthenticated = false;
    unawaited(signOut());
  }

  /// Removes the persisted JWT and replaces the full navigation stack with login.
  /// It is safe to call more than once when a timer and an HTTP response race.
  Future<void> signOut() async {
    if (_isEndingSession || _loginNavigationScheduled) return;

    _isEndingSession = true;
    _loginNavigationScheduled = true;
    try {
      await _tokenStorage.deleteToken();
      _goToLogin();
    } finally {
      _wasAuthenticated = false;
      _isEndingSession = false;
    }
  }

  void _goToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushNamedAndRemoveUntil(loginRoute, (route) => false);
    });
  }

  void dispose() {
    _access.removeListener(_onAccessChanged);
  }
}
