import 'dart:async';

import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:flutter/widgets.dart';

import 'access_control.dart';

/// Keeps the permissions used by the UI aligned with the backend while the
/// JWT continues to represent the authenticated session.
class PermissionSyncService with WidgetsBindingObserver {
  PermissionSyncService(this._apiClient, this._access);

  // A navigation can request a check, but no more than one request is made in
  // this interval. Resume and 403 responses bypass this limit.
  static const _refreshInterval = Duration(minutes: 2);

  final ApiClient _apiClient;
  final AccessControl _access;
  Timer? _timer;
  Future<bool>? _refreshing;
  DateTime? _lastAttemptAt;
  bool _started = false;
  bool _isForeground = true;
  bool _wasAuthenticated = false;

  void start() {
    if (_started) return;
    _started = true;
    _wasAuthenticated = _access.isAuthenticated;
    _access.addListener(_onAccessChanged);
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    if (_wasAuthenticated) unawaited(refresh(force: true));
  }

  Future<bool> refresh({bool force = false}) {
    if (!_access.isAuthenticated) return Future.value(false);
    if (_refreshing != null) return _refreshing!;
    final lastAttemptAt = _lastAttemptAt;
    if (!force &&
        lastAttemptAt != null &&
        DateTime.now().difference(lastAttemptAt) < _refreshInterval) {
      return Future.value(false);
    }
    _lastAttemptAt = DateTime.now();
    return _refreshing = _refreshInternal().whenComplete(() {
      _refreshing = null;
    });
  }

  void _startTimer() {
    _timer ??= Timer.periodic(_refreshInterval, (_) => refresh());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _refreshInternal() async {
    try {
      final response = await _apiClient.dio.get('/session/access');
      final body = response.data;
      if (body is! Map<String, dynamic>) return false;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return false;
      final permissions = data['permissions'];
      if (permissions is! List) return false;

      _access.updatePermissions(
        permissions.whereType<String>(),
      );
      return true;
    } catch (_) {
      // Keep the last confirmed UI state while offline. The backend remains
      // the authority and will still reject revoked operations.
      return false;
    }
  }

  void _onAccessChanged() {
    final isAuthenticated = _access.isAuthenticated;
    if (isAuthenticated && !_wasAuthenticated) unawaited(refresh(force: true));
    _wasAuthenticated = isAuthenticated;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isForeground = true;
      _startTimer();
      unawaited(refresh(force: true));
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _isForeground = false;
      _stopTimer();
    }
  }

  void dispose() {
    _stopTimer();
    _access.removeListener(_onAccessChanged);
    WidgetsBinding.instance.removeObserver(this);
  }
}

/// Triggers a stale-check after navigation without adding a request per route.
class PermissionSyncNavigatorObserver extends NavigatorObserver {
  PermissionSyncNavigatorObserver(this._syncService);

  final PermissionSyncService _syncService;

  void _check() {
    if (_syncService._isForeground) unawaited(_syncService.refresh());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _check();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _check();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _check();
}
