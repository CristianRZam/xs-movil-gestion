import 'dart:convert';

import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';
import 'package:app_movil_sistema/features/notification/presentation/bloc/notification_cubit.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: XsAppBar(
            title: 'Notificaciones',
            actions: [
              if (state.unreadCount > 0)
                IconButton(
                  tooltip: 'Marcar todas como leídas',
                  onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                ),
            ],
          ),
          endDrawer: const XsDrawer(),
          body: _NotificationBody(state: state),
        );
      },
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == NotificationStatus.loading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NotificationStatus.failure && state.notifications.isEmpty) {
      return _FeedbackState(
        icon: Icons.cloud_off_rounded,
        message: state.errorMessage ?? 'No se pudieron cargar las notificaciones.',
        actionLabel: 'Reintentar',
        onAction: () => context.read<NotificationCubit>().loadNotifications(),
      );
    }

    if (state.notifications.isEmpty) {
      return const _FeedbackState(
        icon: Icons.notifications_none_rounded,
        message: 'No tienes notificaciones por ahora.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.notifications.length + (state.errorMessage == null ? 0 : 1),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (state.errorMessage != null && index == 0) {
            return _ErrorBanner(message: state.errorMessage!);
          }
          final offset = state.errorMessage == null ? 0 : 1;
          return _NotificationCard(notification: state.notifications[index - offset]);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(notification.priority, Theme.of(context).colorScheme);
    final isSale = notification.referenceType == 'SALE';

    return Material(
      color: notification.read
          ? Theme.of(context).colorScheme.surface
          : color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openNotificationDetail(context, notification),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.read
                  ? Theme.of(context).dividerColor.withValues(alpha: 0.45)
                  : color.withValues(alpha: 0.50),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_typeIcon(notification.type), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: notification.read
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.message),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 15, color: Theme.of(context).hintColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy · HH:mm').format(notification.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openNotificationDetail(context, notification),
                          icon: Icon(
                            isSale ? Icons.receipt_long_rounded : Icons.visibility_outlined,
                            size: 17,
                          ),
                          label: const Text('Ver detalle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            if (onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

Color _priorityColor(String priority, ColorScheme colors) {
  return switch (priority.toUpperCase()) {
    'CRITICAL' => colors.error,
    'HIGH' => Colors.deepOrange,
    'LOW' => colors.secondary,
    _ => colors.primary,
  };
}

IconData _typeIcon(String type) {
  return switch (type.toUpperCase()) {
    'PAYMENT_RECEIVED' => Icons.payments_rounded,
    'LOW_STOCK' => Icons.inventory_2_outlined,
    'NO_MOVEMENT' => Icons.trending_flat_rounded,
    'CASH_SESSION_OPEN' => Icons.point_of_sale_rounded,
    'INVENTORY_COUNT_PENDING' => Icons.pending_actions_rounded,
    'WASTE_RECORDED' => Icons.delete_outline_rounded,
    'CASH_DIFFERENCE' => Icons.account_balance_wallet_outlined,
    'INVENTORY_COUNT_DIFFERENCE' => Icons.fact_check_outlined,
    _ => Icons.notifications_outlined,
  };
}

Future<void> _openNotificationDetail(
  BuildContext context,
  AppNotification notification,
) async {
  await context.read<NotificationCubit>().markAsRead(notification);
  if (!context.mounted) return;

  final metadata = _metadata(notification.metadata);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _typeIcon(notification.type),
                    color: _priorityColor(
                      notification.priority,
                      Theme.of(sheetContext).colorScheme,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(notification.message),
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Fecha',
                value: DateFormat('dd/MM/yyyy · HH:mm').format(notification.createdAt),
              ),
              if (notification.referenceType != null)
                _DetailRow(
                  icon: Icons.link_rounded,
                  label: 'Referencia',
                  value: '${notification.referenceType} #${notification.referenceId ?? '-'}',
                ),
              if (metadata['saleNumber'] is String)
                _DetailRow(
                  icon: Icons.receipt_long_rounded,
                  label: 'Venta',
                  value: metadata['saleNumber'] as String,
                ),
              if (metadata['paymentMethod'] is String)
                _DetailRow(
                  icon: Icons.payments_rounded,
                  label: 'Método de pago',
                  value: _paymentMethodLabel(metadata['paymentMethod'] as String),
                ),
              if (metadata['amount'] is String)
                _DetailRow(
                  icon: Icons.attach_money_rounded,
                  label: 'Monto recibido',
                  value: 'S/ ${metadata['amount']}',
                ),
              if (metadata['reference'] is String &&
                  (metadata['reference'] as String).isNotEmpty)
                _DetailRow(
                  icon: Icons.tag_rounded,
                  label: 'Referencia de pago',
                  value: metadata['reference'] as String,
                ),
              if (metadata['productName'] is String)
                _DetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Producto',
                  value: metadata['productName'] as String,
                ),
              if (metadata['productCode'] is String)
                _DetailRow(
                  icon: Icons.qr_code_rounded,
                  label: 'Código',
                  value: metadata['productCode'] as String,
                ),
              if (metadata['currentStock'] != null)
                _DetailRow(
                  icon: Icons.inventory_rounded,
                  label: 'Stock actual',
                  value: '${metadata['currentStock']}',
                ),
              if (metadata['threshold'] != null)
                _DetailRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'Stock mínimo configurado',
                  value: '${metadata['threshold']}',
                ),
              if (metadata['daysWithoutMovement'] != null)
                _DetailRow(
                  icon: Icons.event_busy_rounded,
                  label: 'Sin movimiento',
                  value: '${metadata['daysWithoutMovement']} días',
                ),
              if (metadata['cashRegisterId'] != null)
                _DetailRow(
                  icon: Icons.point_of_sale_rounded,
                  label: 'Caja',
                  value: '#${metadata['cashRegisterId']}',
                ),
              if (metadata['countNumber'] is String &&
                  (metadata['countNumber'] as String).isNotEmpty)
                _DetailRow(
                  icon: Icons.fact_check_outlined,
                  label: 'Conteo',
                  value: metadata['countNumber'] as String,
                ),
              if (metadata['status'] is String)
                _DetailRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Estado',
                  value: _countStatusLabel(metadata['status'] as String),
                ),
              if (metadata['openedAt'] is String)
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Iniciado',
                  value: _formatMetadataDate(metadata['openedAt'] as String),
                ),
              if (metadata['openHours'] != null)
                _DetailRow(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Caja abierta',
                  value: '${metadata['openHours']} horas',
                ),
              if (metadata['pendingHours'] != null)
                _DetailRow(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Conteo pendiente',
                  value: '${metadata['pendingHours']} horas',
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Map<String, dynamic> _metadata(String? rawMetadata) {
  if (rawMetadata == null || rawMetadata.isEmpty) return const {};
  try {
    final decoded = jsonDecode(rawMetadata);
    return decoded is Map<String, dynamic> ? decoded : const {};
  } catch (_) {
    return const {};
  }
}

String _paymentMethodLabel(String method) => switch (method) {
      'YAPE' => 'Yape',
      'CARD' => 'Tarjeta',
      'TRANSFER' => 'Transferencia',
      _ => method,
    };

String _countStatusLabel(String status) => switch (status) {
      'OPEN' => 'Abierto',
      'REVIEW' => 'En revisión',
      'CLOSED' => 'Cerrado',
      'CANCELLED' => 'Cancelado',
      _ => status,
    };

String _formatMetadataDate(String rawDate) {
  final parsedDate = DateTime.tryParse(rawDate);
  if (parsedDate == null) return rawDate;
  return DateFormat('dd/MM/yyyy · HH:mm').format(parsedDate);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: Theme.of(context).hintColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
