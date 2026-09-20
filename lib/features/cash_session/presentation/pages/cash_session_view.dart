import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/core/validators/input_validators.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session_close_request.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/bloc/cash_session_bloc.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/bloc/cash_session_event.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/bloc/cash_session_state.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/widgets/%20cash_session_card.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/widgets/cash_session_history_dialog.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/widgets/cash_session_summary_card.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-dialog.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-number-field.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-textfield.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CashSessionView extends StatelessWidget {

  const CashSessionView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final tokenStorage = TokenStorage();

    return FutureBuilder<String?>(
      future: tokenStorage.getToken(),

      builder: (context, snapshot) {

        final hasToken =
            snapshot.hasData &&
                snapshot.data != null;

        return PopScope(
          canPop: !hasToken,

          onPopInvokedWithResult:
              (didPop, result) {

            if (hasToken && !didPop) {
              SystemNavigator.pop();
            }
          },

          child: BlocConsumer<
              CashSessionBloc,
              CashSessionState>(

            listener: (context, state) {

              if (state.savedSession != null) {

                final session = state.savedSession!;

                // Cerrar el diálogo solamente cuando la operación
                // haya terminado correctamente.
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (session.status == "OPEN") {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Caja abierta correctamente",
                      ),
                    ),
                  );

                } else {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Caja cerrada correctamente",
                      ),
                    ),
                  );
                }

                context
                    .read<CashSessionBloc>()
                    .add(
                  const ClearSavedCashSession(),
                );
              }

              if (state.history != null) {

                openCashSessionHistoryDialog(
                  context,
                  state.history!,
                );

                context
                    .read<CashSessionBloc>()
                    .add(
                  const ClearCashSessionHistory(),
                );
              }

              if (state.status ==
                  CashSessionStatus.failure &&
                  state.errorMessage != null) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage!,
                    ),
                  ),
                );

                context
                    .read<CashSessionBloc>()
                    .add(
                  const ClearCashSessionError(),
                );
              }
            },

            builder: (context, state) {

              final session =
                  state.currentSession;

              final isOpen =
                  session != null &&
                      session.status == "OPEN";

              return Scaffold(

                backgroundColor:
                isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,

                appBar: const XsAppBar(
                  title: "Caja",
                  backIcon: false,
                ),

                endDrawer: const XsDrawer(),

                body: SafeArea(

                  child: SingleChildScrollView(

                    physics:
                    const BouncingScrollPhysics(),

                    padding:
                    const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      40,
                    ),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        if (isOpen) ...[

                          CashSessionCard(
                            session: session,
                            onClose: () {

                              openCloseCashSessionDialog(
                                context,
                                session,
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [

                              Expanded(
                                child:
                                CashSessionSummaryCard(
                                  title: "Apertura",
                                  value:
                                  "S/ ${session.openingAmount.toStringAsFixed(2)}",
                                  icon:
                                  Icons.lock_open_rounded,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child:
                                CashSessionSummaryCard(
                                  title: "Esperado",
                                  value:
                                  "S/ ${(session.expectedAmount ?? 0).toStringAsFixed(2)}",
                                  icon:
                                  Icons.calculate_outlined,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child:
                                CashSessionSummaryCard(
                                  title: "Estado",
                                  value: "ABIERTA",
                                  icon:
                                  Icons.point_of_sale_rounded,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,

                            child:
                            FilledButton.icon(
                              onPressed: () {

                                openCloseCashSessionDialog(
                                  context,
                                  session,
                                );
                              },

                              icon: const Icon(
                                Icons.lock_rounded,
                              ),

                              label: const Text(
                                "Cerrar caja",
                              ),

                              style:
                              FilledButton.styleFrom(
                                backgroundColor:
                                Colors.red,
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                        ] else ...[

                          _ClosedCashCard(
                            onOpen: () {

                              openOpenCashSessionDialog(
                                context,
                              );
                            },
                          ),

                        ],

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,

                          child: OutlinedButton.icon(
                            onPressed: () {

                              context
                                  .read<
                                  CashSessionBloc>()
                                  .add(
                                const
                                LoadCashSessionHistory(),
                              );
                            },

                            icon: const Icon(
                              Icons.history_rounded,
                            ),

                            label: const Text(
                              "Historial de cajas",
                            ),

                            style:
                            OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


class _ClosedCashCard extends StatelessWidget {

  final VoidCallback onOpen;

  const _ClosedCashCard({
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
    Theme.of(context);

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
        BorderRadius.circular(24),
      ),

      child: Column(

        children: [

          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color:
              AppColors.primary
                  .withValues(
                alpha: .10,
              ),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.lock_open_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "No hay una caja abierta",
            style: TextStyle(
              fontSize: 19,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Abra una caja para comenzar a registrar operaciones.",
            textAlign: TextAlign.center,
            style:
            theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,

            child: FilledButton.icon(
              onPressed: onOpen,

              icon: const Icon(
                Icons.lock_open_rounded,
              ),

              label: const Text(
                "Abrir caja",
              ),

              style:
              FilledButton.styleFrom(
                backgroundColor:
                AppColors.primary,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


void openOpenCashSessionDialog(
    BuildContext parentContext,
    ) {

  final amountController =
  TextEditingController();

  final commentController =
  TextEditingController();

  final formKey =
  GlobalKey<FormState>();

  showDialog(
    context: parentContext,

    builder: (_) {

      return Form(
        key: formKey,

        child: XsDialog(

          title: "Abrir caja",

          confirmText: "Abrir caja",

          onConfirm: () {

            if (!(formKey.currentState
                ?.validate() ??
                false)) {
              return;
            }

            /*
             * Aquí estamos siguiendo la entidad
             * actual que construimos.
             *
             * Idealmente esto debería utilizar
             * CashSessionOpenRequest.
             */

            final request =
            CashSession(
              id: 0,
              cashRegisterId: 1,
              openedBy: 0,
              openedAt:
              DateTime.now(),

              openingAmount:
              double.parse(
                amountController.text,
              ),

              status: "OPEN",

              openingComment:
              commentController.text
                  .trim()
                  .isEmpty
                  ? null
                  : commentController.text
                  .trim(),

              deleted: false,
            );

            parentContext
                .read<CashSessionBloc>()
                .add(
              OpenCashSession(request),
            );

          },

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [

              XsNumberField(
                controller:
                amountController,

                labelText:
                "Monto de apertura",

                decimal: true,

                prefixIcon:
                const Icon(
                  Icons.attach_money,
                ),

                validator: (value) =>
                    composeValidators([
                      InputValidators.requiredField(
                        "Ingrese el monto de apertura",
                      ),
                    ], value),
              ),

              const SizedBox(height: 16),

              XsTextField(
                controller:
                commentController,

                labelText:
                "Comentario",

                keyboardType:
                TextInputType.multiline,

                prefixIcon:
                const Icon(
                  Icons.description_outlined,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


void openCloseCashSessionDialog(
    BuildContext parentContext,
    CashSession session,
    ) {

  final closingAmountController =
  TextEditingController();

  final expectedAmountController =
  TextEditingController(
    text:
    (session.expectedAmount ?? 0)
        .toStringAsFixed(2),
  );

  final differenceController =
  TextEditingController();

  final commentController =
  TextEditingController();

  final formKey =
  GlobalKey<FormState>();

  showDialog(
    context: parentContext,

    builder: (_) {

      return StatefulBuilder(

        builder: (
            context,
            setState,
            ) {

          void calculateDifference() {

            final closing =
                double.tryParse(
                  closingAmountController
                      .text,
                ) ??
                    0;

            final expected =
                double.tryParse(
                  expectedAmountController
                      .text,
                ) ??
                    0;

            final difference =
                closing - expected;

            differenceController.text =
                difference.toStringAsFixed(2);

            setState(() {});
          }

          return Form(
            key: formKey,

            child: XsDialog(

              title: "Cerrar caja",

              confirmText: "Cerrar caja",

              onConfirm: () {

                if (!(formKey.currentState
                    ?.validate() ??
                    false)) {
                  return;
                }

                final closingAmount =
                double.parse(
                  closingAmountController
                      .text,
                );

                final expectedAmount =
                double.parse(
                  expectedAmountController
                      .text,
                );

                final difference =
                    closingAmount -
                        expectedAmount;

                final request =
                CashSessionCloseRequest(
                  id: session.id,
                  closingAmount:
                  closingAmount,
                  expectedAmount:
                  expectedAmount,
                  difference:
                  difference,
                  closingComment:
                  commentController.text
                      .trim()
                      .isEmpty
                      ? null
                      : commentController
                      .text
                      .trim(),
                );

                parentContext
                    .read<CashSessionBloc>()
                    .add(
                  CloseCashSession(
                    request,
                  ),
                );
              },

              child: Column(
                mainAxisSize:
                MainAxisSize.min,

                children: [

                  XsNumberField(
                    controller:
                    expectedAmountController,

                    labelText:
                    "Monto esperado",

                    decimal: true,

                    prefixIcon:
                    const Icon(
                      Icons.calculate_outlined,
                    ),

                    validator:
                        (value) =>
                        composeValidators([
                          InputValidators.requiredField(
                            "Ingrese el monto esperado",
                          ),
                        ], value),
                  ),

                  const SizedBox(height: 14),

                  XsNumberField(
                    controller:
                    closingAmountController,

                    labelText:
                    "Monto contado",

                    decimal: true,

                    prefixIcon:
                    const Icon(
                      Icons.payments_outlined,
                    ),

                    validator:
                        (value) =>
                        composeValidators([
                          InputValidators.requiredField(
                            "Ingrese el monto contado",
                          ),
                        ], value),

                    onChanged: (_) {
                      calculateDifference();
                    },
                  ),

                  const SizedBox(height: 14),

                  XsNumberField(
                    controller:
                    differenceController,

                    labelText:
                    "Diferencia",

                    decimal: true,

                    prefixIcon:
                    const Icon(
                      Icons.compare_arrows_rounded,
                    ),

                  ),

                  const SizedBox(height: 14),

                  XsTextField(
                    controller:
                    commentController,

                    labelText:
                    "Comentario de cierre",

                    keyboardType:
                    TextInputType.multiline,

                    prefixIcon:
                    const Icon(
                      Icons.description_outlined,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}