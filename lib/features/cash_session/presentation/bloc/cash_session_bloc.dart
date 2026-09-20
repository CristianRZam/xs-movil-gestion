import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cash_session.dart';
import '../../domain/entities/cash_session_close_request.dart';
import '../../domain/usecases/close_cash_session_usecase.dart';
import '../../domain/usecases/exists_open_cash_session_usecase.dart';
import '../../domain/usecases/get_cash_session_history_usecase.dart';
import '../../domain/usecases/get_current_cash_session_usecase.dart';
import '../../domain/usecases/open_cash_session_usecase.dart';

import 'cash_session_event.dart';
import 'cash_session_state.dart';

class CashSessionBloc
    extends Bloc<CashSessionEvent, CashSessionState> {

  final OpenCashSessionUseCase openCashSessionUseCase;

  final GetCurrentCashSessionUseCase
  getCurrentCashSessionUseCase;

  final ExistsOpenCashSessionUseCase
  existsOpenCashSessionUseCase;

  final CloseCashSessionUseCase
  closeCashSessionUseCase;

  final GetCashSessionHistoryUseCase
  getCashSessionHistoryUseCase;

  CashSessionBloc(
      this.openCashSessionUseCase,
      this.getCurrentCashSessionUseCase,
      this.existsOpenCashSessionUseCase,
      this.closeCashSessionUseCase,
      this.getCashSessionHistoryUseCase,
      ) : super(
    const CashSessionState(),
  ) {

    on<LoadCurrentCashSession>(
      _onLoadCurrentSession,
    );

    on<CheckOpenCashSession>(
      _onCheckOpenSession,
    );

    on<OpenCashSession>(
      _onOpenSession,
    );

    on<CloseCashSession>(
      _onCloseSession,
    );

    on<LoadCashSessionHistory>(
      _onLoadHistory,
    );

    on<ClearSavedCashSession>(
      _onClearSavedSession,
    );

    on<ClearCashSessionHistory>(
      _onClearHistory,
    );

    on<ClearCashSessionError>(
      _onClearError,
    );
  }

  Future<void> _onLoadCurrentSession(
      LoadCurrentCashSession event,
      Emitter<CashSessionState> emit,
      ) async {

    emit(
      state.copyWith(
        status: CashSessionStatus.loading,
      ),
    );

    final result =
    await getCurrentCashSessionUseCase();

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            status: CashSessionStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },
          (session) {
        emit(
          state.copyWith(
            status: CashSessionStatus.success,
            currentSession: session,
            existsOpen: true,
          ),
        );
      },
    );
  }

  Future<void> _onCheckOpenSession(
      CheckOpenCashSession event,
      Emitter<CashSessionState> emit,
      ) async {

    emit(
      state.copyWith(
        status: CashSessionStatus.loading,
      ),
    );

    final existsResult =
    await existsOpenCashSessionUseCase();

    await existsResult.fold(
          (failure) async {

        emit(
          state.copyWith(
            status: CashSessionStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },

          (exists) async {

        // No existe una caja abierta
        if (!exists) {

          emit(
            state.copyWith(
              status: CashSessionStatus.success,
              existsOpen: false,
              currentSession: null,
            ),
          );

          return;
        }

        // Existe una caja abierta,
        // ahora obtenemos sus datos
        final sessionResult =
        await getCurrentCashSessionUseCase();

        await sessionResult.fold(
              (failure) async {

            emit(
              state.copyWith(
                status: CashSessionStatus.failure,
                errorCode: failure.code,
                errorMessage: failure.message,
              ),
            );
          },

              (session) async {

            emit(
              state.copyWith(
                status: CashSessionStatus.success,
                existsOpen: true,
                currentSession: session,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onOpenSession(
      OpenCashSession event,
      Emitter<CashSessionState> emit,
      ) async {

    emit(
      state.copyWith(
        status: CashSessionStatus.loading,
      ),
    );

    final result =
    await openCashSessionUseCase(
      event.request,
    );

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            status: CashSessionStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },
          (session) {
        emit(
          state.copyWith(
            status: CashSessionStatus.success,
            savedSession: session,
            currentSession: session,
            existsOpen: true,
          ),
        );
      },
    );
  }

  Future<void> _onCloseSession(
      CloseCashSession event,
      Emitter<CashSessionState> emit,
      ) async {

    emit(
      state.copyWith(
        status: CashSessionStatus.loading,
      ),
    );

    final result =
    await closeCashSessionUseCase(
      event.request,
    );

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            status: CashSessionStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },
          (session) {
        emit(
          state.copyWith(
            status: CashSessionStatus.success,
            savedSession: session,
            currentSession: null,
            existsOpen: false,
          ),
        );
      },
    );
  }

  Future<void> _onLoadHistory(
      LoadCashSessionHistory event,
      Emitter<CashSessionState> emit,
      ) async {

    emit(
      state.copyWith(
        status: CashSessionStatus.loading,
      ),
    );

    final result =
    await getCashSessionHistoryUseCase();

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            status: CashSessionStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },
          (history) {
        emit(
          state.copyWith(
            status: CashSessionStatus.success,
            history: history,
          ),
        );
      },
    );
  }

  void _onClearSavedSession(
      ClearSavedCashSession event,
      Emitter<CashSessionState> emit,
      ) {

    emit(
      state.copyWith(
        savedSession: null,
      ),
    );
  }

  void _onClearHistory(
      ClearCashSessionHistory event,
      Emitter<CashSessionState> emit,
      ) {

    emit(
      state.copyWith(
        history: null,
      ),
    );
  }

  void _onClearError(
      ClearCashSessionError event,
      Emitter<CashSessionState> emit,
      ) {

    emit(
      state.copyWith(
        status: CashSessionStatus.initial,
        errorCode: null,
        errorMessage: null,
      ),
    );
  }
}