import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session_close_request.dart';

abstract class CashSessionEvent {
  const CashSessionEvent();
}

/// Obtener caja actual
class LoadCurrentCashSession extends CashSessionEvent {
  const LoadCurrentCashSession();
}

/// Verificar si existe caja abierta
class CheckOpenCashSession extends CashSessionEvent {
  const CheckOpenCashSession();
}

/// Abrir caja
class OpenCashSession extends CashSessionEvent {

  final CashSession request;

  const OpenCashSession(
      this.request,
      );
}

/// Cerrar caja
class CloseCashSession extends CashSessionEvent {

  final CashSessionCloseRequest request;

  const CloseCashSession(
      this.request,
      );
}

/// Obtener historial
class LoadCashSessionHistory extends CashSessionEvent {
  const LoadCashSessionHistory();
}

/// Limpiar sesión guardada
class ClearSavedCashSession extends CashSessionEvent {
  const ClearSavedCashSession();
}

/// Limpiar historial
class ClearCashSessionHistory extends CashSessionEvent {
  const ClearCashSessionHistory();
}

/// Limpiar errores
class ClearCashSessionError extends CashSessionEvent {
  const ClearCashSessionError();
}