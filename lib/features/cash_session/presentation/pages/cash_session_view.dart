import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/cash_session_sales_summary.dart';
import 'package:app_movil_sistema/features/sale/domain/usecases/sale_usecases.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/core/validators/input_validators.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session_close_request.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/bloc/cash_session_bloc.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/bloc/cash_session_event.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/bloc/cash_session_state.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/widgets/cash_session_card.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/widgets/cash_session_history_dialog.dart';
import 'package:app_movil_sistema/features/cash_session/presentation/widgets/cash_session_summary_card.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-dialog.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-number-field.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-textfield.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/payment_method_style.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CashSessionView extends StatelessWidget {
  const CashSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tokenStorage = getIt<TokenStorage>();

    return FutureBuilder<String?>(
      future: tokenStorage.getToken(),

      builder: (context, snapshot) {
        final hasToken = snapshot.hasData && snapshot.data != null;

        return PopScope(
          canPop: !hasToken,

          onPopInvokedWithResult: (didPop, result) {
            if (hasToken && !didPop) {
              SystemNavigator.pop();
            }
          },

          child: BlocConsumer<CashSessionBloc, CashSessionState>(
            listener: (context, state) {
              if (state.savedSession != null) {
                final session = state.savedSession!;

                // Cerrar el diálogo solamente cuando la operación
                // haya terminado correctamente.
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (session.status == "OPEN") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Caja abierta correctamente")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Caja cerrada correctamente")),
                  );
                }

                context.read<CashSessionBloc>().add(
                  const ClearSavedCashSession(),
                );
              }

              if (state.history != null) {
                openCashSessionHistoryDialog(context, state.history!);

                context.read<CashSessionBloc>().add(
                  const ClearCashSessionHistory(),
                );
              }

              if (state.status == CashSessionStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));

                context.read<CashSessionBloc>().add(
                  const ClearCashSessionError(),
                );
              }
            },

            builder: (context, state) {
              final session = state.currentSession;

              final isOpen = session != null && session.status == "OPEN";

              return Scaffold(
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,

                appBar: const XsAppBar(title: "Caja", backIcon: false),

                endDrawer: const XsDrawer(),

                floatingActionButton: isOpen
                    ? FloatingActionButton.small(
                        tooltip: 'Actualizar montos de caja',
                        onPressed: () => context.read<CashSessionBloc>().add(
                          const LoadCurrentCashSession(),
                        ),
                        child: const Icon(Icons.refresh_rounded),
                      )
                    : null,

                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        if (isOpen) ...[
                          CashSessionCard(
                            session: session,
                            onClose: () {
                              openCloseCashSessionDialog(context, session);
                            },
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: CashSessionSummaryCard(
                                  title: "Apertura",
                                  value:
                                      "S/ ${session.openingAmount.toStringAsFixed(2)}",
                                  icon: Icons.lock_open_rounded,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: CashSessionSummaryCard(
                                  title: "Esperado",
                                  value:
                                      "S/ ${(session.expectedAmount ?? 0).toStringAsFixed(2)}",
                                  icon: Icons.calculate_outlined,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: CashSessionSummaryCard(
                                  title: "Estado",
                                  value: "ABIERTA",
                                  icon: Icons.point_of_sale_rounded,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          OutlinedButton.icon(
                            onPressed: () =>
                                _openCashSalesHistory(context, session.id),
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('Ver ventas de esta caja'),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,

                            child: FilledButton.icon(
                              onPressed: () {
                                openCloseCashSessionDialog(context, session);
                              },

                              icon: const Icon(Icons.lock_rounded),

                              label: const Text("Cerrar caja"),

                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          _ClosedCashCard(
                            onOpen: () {
                              openOpenCashSessionDialog(context);
                            },
                          ),
                        ],

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,

                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<CashSessionBloc>().add(
                                const LoadCashSessionHistory(),
                              );
                            },

                            icon: const Icon(Icons.history_rounded),

                            label: const Text("Historial de cajas"),

                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
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

  const _ClosedCashCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .10),

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
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            "Abra una caja para comenzar a registrar operaciones.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,

            child: FilledButton.icon(
              onPressed: onOpen,

              icon: const Icon(Icons.lock_open_rounded),

              label: const Text("Abrir caja"),

              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void openOpenCashSessionDialog(BuildContext parentContext) {
  final amountController = TextEditingController();

  final commentController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  showDialog(
    context: parentContext,

    builder: (_) {
      return Form(
        key: formKey,

        child: XsDialog(
          title: "Abrir caja",

          confirmText: "Abrir caja",

          onConfirm: () {
            if (!(formKey.currentState?.validate() ?? false)) {
              return;
            }

            /*
             * Aquí estamos siguiendo la entidad
             * actual que construimos.
             *
             * Idealmente esto debería utilizar
             * CashSessionOpenRequest.
             */

            final request = CashSession(
              id: 0,
              cashRegisterId: 1,
              openedBy: 0,
              openedAt: DateTime.now(),

              openingAmount: double.parse(amountController.text),

              status: "OPEN",

              openingComment: commentController.text.trim().isEmpty
                  ? null
                  : commentController.text.trim(),

              deleted: false,
            );

            parentContext.read<CashSessionBloc>().add(OpenCashSession(request));
          },

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              XsNumberField(
                controller: amountController,

                labelText: "Monto de apertura",

                decimal: true,

                prefixIcon: const Icon(Icons.attach_money),

                validator: (value) => composeValidators([
                  InputValidators.requiredField("Ingrese el monto de apertura"),
                ], value),
              ),

              const SizedBox(height: 16),

              XsTextField(
                controller: commentController,

                labelText: "Comentario",

                keyboardType: TextInputType.multiline,

                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _openCashSalesHistory(BuildContext context, int sessionId) async {
  final result = await getIt<GetCashSessionSalesSummaryUseCase>()(sessionId);
  if (!context.mounted) return;

  result.fold(
    (failure) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failure.message))),
    (summary) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CashSalesHistory(summary: summary),
    ),
  );
}

class _CashSalesHistory extends StatefulWidget {
  final CashSessionSalesSummary summary;
  const _CashSalesHistory({required this.summary});

  @override
  State<_CashSalesHistory> createState() => _CashSalesHistoryState();
}

class _CashSalesHistoryState extends State<_CashSalesHistory> {
  @override
  Widget build(BuildContext context) => SafeArea(
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      maxChildSize: .92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Ventas de la caja',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Total vendido: S/ ${widget.summary.totalSold.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 28),
          const Text(
            'Resumen por método de pago',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...widget.summary.paymentMethods.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                PaymentMethodStyle.icon(item.paymentMethod),
                color: PaymentMethodStyle.color(item.paymentMethod),
              ),
              title: Text(_cashPaymentLabel(item.paymentMethod)),
              trailing: Text('S/ ${item.total.toStringAsFixed(2)}'),
            ),
          ),
          const Divider(height: 28),
          const Text(
            'Ventas registradas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (widget.summary.sales.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('No hay ventas registradas en esta caja.'),
            ),
          ...widget.summary.sales.map(
            (sale) => ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(sale.saleNumber),
              subtitle: Text(
                '${sale.createdByName ?? 'Usuario no disponible'} · ${sale.payments.map((p) => _cashPaymentLabel(p.paymentMethod)).join(' + ')}',
              ),
              trailing: Text('S/ ${sale.total.toStringAsFixed(2)}'),
              children: [
                ...sale.items
                    .map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                        ),
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(
                          item.productName ?? 'Producto #${item.productId}',
                        ),
                        subtitle: Text(
                          '${item.quantity.toInt()} × S/ ${item.unitPrice.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          'S/ ${item.subtotal.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                if (sale.discount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Descuento aplicado',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '-S/ ${sale.discount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    'Pagos de esta venta',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...sale.payments.map(
                  (payment) => ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 16, right: 8),
                    leading: Icon(
                      PaymentMethodStyle.icon(payment.paymentMethod),
                      color: PaymentMethodStyle.color(payment.paymentMethod),
                    ),
                    title: Text(_cashPaymentLabel(payment.paymentMethod)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monto aplicado: S/ ${payment.amount.toStringAsFixed(2)}'),
                        if (payment.receivedAmount != null)
                          Text('Recibido: S/ ${payment.receivedAmount!.toStringAsFixed(2)}'),
                        if (payment.changeAmount != null && payment.changeAmount! > 0)
                          Text('Vuelto: S/ ${payment.changeAmount!.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Text(
                      'S/ ${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CashCloseReconciliationSummary extends StatelessWidget {
  const _CashCloseReconciliationSummary({required this.summary});

  final CashSessionSalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = summary.totalSold.toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: .22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Resumen para el arqueo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CashCloseMetric(
                  label: 'Ventas incluidas',
                  value: '${summary.sales.length}',
                ),
              ),
              Expanded(
                child: _CashCloseMetric(
                  label: 'Total vendido',
                  value: 'S/ $total',
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (summary.paymentMethods.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            Text(
              'Por método de pago',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            ...summary.paymentMethods.map(
              (payment) => Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Icon(
                      PaymentMethodStyle.icon(payment.paymentMethod),
                      size: 18,
                      color: PaymentMethodStyle.color(payment.paymentMethod),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_cashPaymentLabel(payment.paymentMethod)),
                    ),
                    Text(
                      'S/ ${payment.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CashCloseMetric extends StatelessWidget {
  const _CashCloseMetric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 2),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

String _cashPaymentLabel(String method) => switch (method) {
  'CASH' => 'Efectivo',
  'YAPE' => 'Yape',
  'CARD' => 'Tarjeta',
  'TRANSFER' => 'Transferencia',
  _ => method,
};

Future<void> openCloseCashSessionDialog(
  BuildContext parentContext,
  CashSession session,
) async {
  CashSessionSalesSummary? salesSummary;
  final summaryResult = await getIt<GetCashSessionSalesSummaryUseCase>()(
    session.id,
  );
  if (!parentContext.mounted) return;

  summaryResult.fold(
    (failure) => ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text(
          'No se pudo cargar el detalle de ventas: ${failure.message}',
        ),
      ),
    ),
    (summary) => salesSummary = summary,
  );

  final closingAmountController = TextEditingController();

  final expectedAmountController = TextEditingController(
    text: (session.expectedAmount ?? 0).toStringAsFixed(2),
  );

  var calculatedDifference = 0.0;

  final commentController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: parentContext,

    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          void calculateDifference() {
            final closing = double.tryParse(closingAmountController.text) ?? 0;

            final expected =
                double.tryParse(expectedAmountController.text) ?? 0;

            final difference = closing - expected;

            calculatedDifference = difference;

            setState(() {});
          }

          final isBalanced = calculatedDifference.abs() < .005;
          final isSurplus = calculatedDifference > 0;
          final differenceColor = isBalanced
              ? Colors.blue
              : (isSurplus ? Colors.green : Colors.red);
          final differenceLabel = isBalanced
              ? 'Caja cuadrada'
              : (isSurplus ? 'Sobrante detectado' : 'Faltante detectado');

          return Form(
            key: formKey,

            child: XsDialog(
              title: "Cerrar caja",

              confirmText: "Cerrar caja",

              onConfirm: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final closingAmount = double.parse(
                  closingAmountController.text,
                );

                final expectedAmount = double.parse(
                  expectedAmountController.text,
                );

                final difference = closingAmount - expectedAmount;

                final request = CashSessionCloseRequest(
                  id: session.id,
                  closingAmount: closingAmount,
                  expectedAmount: expectedAmount,
                  difference: difference,
                  closingComment: commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                );

                parentContext.read<CashSessionBloc>().add(
                  CloseCashSession(request),
                );
              },

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  if (salesSummary != null) ...[
                    _CashCloseReconciliationSummary(summary: salesSummary!),
                    const SizedBox(height: 16),
                  ],
                  XsNumberField(
                    controller: expectedAmountController,

                    labelText: "Monto esperado (automático)",

                    decimal: true,

                    readOnly: true,

                    prefixIcon: const Icon(Icons.calculate_outlined),
                  ),

                  const SizedBox(height: 14),

                  XsNumberField(
                    controller: closingAmountController,

                    labelText: "Monto contado",

                    decimal: true,

                    prefixIcon: const Icon(Icons.payments_outlined),

                    validator: (value) => composeValidators([
                      InputValidators.requiredField("Ingrese el monto contado"),
                    ], value),

                    onChanged: (_) {
                      calculateDifference();
                    },
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: differenceColor.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: differenceColor.withValues(alpha: .28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isBalanced
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_rounded,
                          color: differenceColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                differenceLabel,
                                style: TextStyle(
                                  color: differenceColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Diferencia: S/ ${calculatedDifference.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  XsTextField(
                    controller: commentController,

                    labelText: "Comentario de cierre (obligatorio)",

                    keyboardType: TextInputType.multiline,

                    prefixIcon: const Icon(Icons.description_outlined),

                    autoValidate: true,

                    validator: (value) => InputValidators.requiredField(
                      'Indique un comentario para cerrar la caja',
                    )(value),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  closingAmountController.dispose();
  expectedAmountController.dispose();
  commentController.dispose();
}
