import 'package:app_movil_sistema/features/cash_session/domain/usecases/close_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/get_cash_session_history_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/get_current_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/bloc/cash_session_event.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/service_locator.dart';

import '../bloc/cash_session_bloc.dart';
import '../bloc/cash_session_state.dart';
import 'cash_session_view.dart';

class CashSessionScreen extends StatelessWidget {

  const CashSessionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => CashSessionBloc(
        getIt<OpenCashSessionUseCase>(),
        getIt<GetCurrentCashSessionUseCase>(),
        getIt<ExistsOpenCashSessionUseCase>(),
        getIt<CloseCashSessionUseCase>(),
        getIt<GetCashSessionHistoryUseCase>(),
      )..add(
        const CheckOpenCashSession(),
      ),

      child: BlocBuilder<
          CashSessionBloc,
          CashSessionState>(
        builder: (context, state) {

          return LoadingOverlay(
            isLoading:
            state.status ==
                CashSessionStatus.loading,

            child: const CashSessionView(),
          );
        },
      ),
    );
  }
}