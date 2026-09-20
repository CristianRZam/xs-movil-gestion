import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';

enum CashSessionStatus {
  initial,
  loading,
  success,
  failure,
}

class CashSessionState {

  final CashSessionStatus status;

  final CashSession? currentSession;

  final List<CashSession>? history;

  final bool? existsOpen;

  final CashSession? savedSession;

  final int? errorCode;

  final String? errorMessage;

  const CashSessionState({
    this.status = CashSessionStatus.initial,
    this.currentSession,
    this.history,
    this.existsOpen,
    this.savedSession,
    this.errorCode,
    this.errorMessage,
  });

  CashSessionState copyWith({
    CashSessionStatus? status,

    Object? currentSession = _sentinel,

    Object? history = _sentinel,

    Object? existsOpen = _sentinel,

    Object? savedSession = _sentinel,

    int? errorCode,

    String? errorMessage,
  }) {
    return CashSessionState(
      status: status ?? this.status,

      currentSession: identical(
        currentSession,
        _sentinel,
      )
          ? this.currentSession
          : currentSession as CashSession?,

      history: identical(
        history,
        _sentinel,
      )
          ? this.history
          : history as List<CashSession>?,

      existsOpen: identical(
        existsOpen,
        _sentinel,
      )
          ? this.existsOpen
          : existsOpen as bool?,

      savedSession: identical(
        savedSession,
        _sentinel,
      )
          ? this.savedSession
          : savedSession as CashSession?,

      errorCode: errorCode ?? this.errorCode,

      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static const _sentinel = Object();
}