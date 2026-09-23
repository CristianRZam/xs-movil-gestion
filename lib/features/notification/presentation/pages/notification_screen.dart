import 'dart:convert';
import 'dart:async';

import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/notification_filter.dart';
import 'package:app_movil_sistema/features/notification/presentation/bloc/notification_cubit.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
                  onPressed: () =>
                      context.read<NotificationCubit>().markAllAsRead(),
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                ),
            ],
          ),
          endDrawer: const XsDrawer(),
          body: _NotificationBody(
            state: state,
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onOpenFilters: () => _openFilters(state.filter, state.visibleDays),
          ),
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<NotificationCubit>().updateSearch(value);
    });
  }

  Future<void> _openFilters(NotificationFilter filter, int visibleDays) async {
    final updated = await showModalBottomSheet<NotificationFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NotificationFilterSheet(
        initialFilter: filter,
        visibleDays: visibleDays,
      ),
    );
    if (updated != null && mounted) {
      await context.read<NotificationCubit>().updateFilter(updated);
    }
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onOpenFilters,
  });

  final NotificationState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar en notificaciones',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: const Icon(Icons.clear_rounded),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: state.filter.hasActiveFilters,
                smallSize: 8,
                child: IconButton.outlined(
                  tooltip: 'Filtrar notificaciones',
                  onPressed: onOpenFilters,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent(context)),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (state.status == NotificationStatus.loading &&
        state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == NotificationStatus.failure &&
        state.notifications.isEmpty) {
      return _FeedbackState(
        icon: Icons.cloud_off_rounded,
        message:
            state.errorMessage ?? 'No se pudieron cargar las notificaciones.',
        actionLabel: 'Reintentar',
        onAction: () => context.read<NotificationCubit>().loadNotifications(),
      );
    }
    if (state.notifications.isEmpty) {
      return const _FeedbackState(
        icon: Icons.notifications_none_rounded,
        message: 'No hay notificaciones con estos filtros.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            state.notifications.length + (state.errorMessage == null ? 0 : 1),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (state.errorMessage != null && index == 0) {
            return _ErrorBanner(message: state.errorMessage!);
          }
          final offset = state.errorMessage == null ? 0 : 1;
          return _NotificationCard(
            notification: state.notifications[index - offset],
          );
        },
      ),
    );
  }
}

class _NotificationFilterSheet extends StatefulWidget {
  const _NotificationFilterSheet({
    required this.initialFilter,
    required this.visibleDays,
  });

  final NotificationFilter initialFilter;
  final int visibleDays;

  @override
  State<_NotificationFilterSheet> createState() =>
      _NotificationFilterSheetState();
}

class _NotificationFilterSheetState extends State<_NotificationFilterSheet> {
  String? _type;
  String? _priority;
  bool? _read;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    _type = filter.type;
    _priority = filter.priority;
    _read = filter.read;
    _fromDate = filter.fromDate;
    _toDate = filter.toDate;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar notificaciones',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Por configuración del negocio, solo puedes consultar alertas de los últimos ${widget.visibleDays} día(s).',
                ),
              ),
              const SizedBox(height: 18),
              _FilterDropdown(
                label: 'Tipo',
                value: _type,
                values: const {
                  'PAYMENT_RECEIVED': 'Pago digital',
                  'LOW_STOCK': 'Stock bajo',
                  'NO_MOVEMENT': 'Sin movimiento',
                  'CASH_SESSION_OPEN': 'Caja abierta',
                  'INVENTORY_COUNT_PENDING': 'Conteo pendiente',
                  'WASTE_RECORDED': 'Merma registrada',
                  'CASH_DIFFERENCE': 'Diferencia de caja',
                  'INVENTORY_COUNT_DIFFERENCE': 'Diferencia de conteo',
                },
                onChanged: (value) => setState(() => _type = value),
              ),
              const SizedBox(height: 12),
              _FilterDropdown(
                label: 'Prioridad',
                value: _priority,
                values: const {
                  'LOW': 'Baja',
                  'NORMAL': 'Normal',
                  'HIGH': 'Alta',
                  'CRITICAL': 'Crítica',
                },
                onChanged: (value) => setState(() => _priority = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Estado de lectura',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todas'),
                    selected: _read == null,
                    onSelected: (_) => setState(() => _read = null),
                  ),
                  ChoiceChip(
                    label: const Text('No leídas'),
                    selected: _read == false,
                    onSelected: (_) => setState(() => _read = false),
                  ),
                  ChoiceChip(
                    label: const Text('Leídas'),
                    selected: _read == true,
                    onSelected: (_) => setState(() => _read = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Fecha', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range_rounded),
                label: Text(_dateRangeLabel()),
              ),
              if (_fromDate != null || _toDate != null)
                TextButton.icon(
                  onPressed: () => setState(() {
                    _fromDate = null;
                    _toDate = null;
                  }),
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Quitar rango de fechas'),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, const NotificationFilter()),
                    child: const Text('Limpiar'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      NotificationFilter(
                        type: _type,
                        priority: _priority,
                        read: _read,
                        fromDate: _fromDate,
                        toDate: _toDate,
                        search: widget.initialFilter.search,
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final firstAllowedDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: widget.visibleDays - 1));
    final initialStart =
        _fromDate != null && _fromDate!.isBefore(firstAllowedDate)
        ? firstAllowedDate
        : _fromDate;
    final initialEnd = _toDate != null && _toDate!.isAfter(now) ? now : _toDate;
    final range = await showDateRangePicker(
      context: context,
      firstDate: firstAllowedDate,
      lastDate: now,
      initialDateRange: initialStart == null || initialEnd == null
          ? null
          : DateTimeRange(start: initialStart, end: initialEnd),
      locale: const Locale('es'),
    );
    if (range != null) {
      setState(() {
        _fromDate = range.start;
        _toDate = range.end;
      });
    }
  }

  String _dateRangeLabel() {
    if (_fromDate == null || _toDate == null) {
      return 'Seleccionar rango de fechas';
    }
    return '${DateFormat('dd/MM/yyyy').format(_fromDate!)} - ${DateFormat('dd/MM/yyyy').format(_toDate!)}';
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final Map<String, String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    items: [
      const DropdownMenuItem(value: null, child: Text('Todos')),
      ...values.entries.map(
        (entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ),
    ],
    onChanged: onChanged,
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(
      notification.priority,
      Theme.of(context).colorScheme,
    );
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
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
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.message),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'dd/MM/yyyy · HH:mm',
                            ).format(notification.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _openNotificationDetail(context, notification),
                          icon: Icon(
                            isSale
                                ? Icons.receipt_long_rounded
                                : Icons.visibility_outlined,
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
  final action = _notificationAction(notification);
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
                      style: Theme.of(sheetContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
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
                value: DateFormat(
                  'dd/MM/yyyy · HH:mm',
                ).format(notification.createdAt),
              ),
              if (notification.referenceType != null)
                _DetailRow(
                  icon: Icons.link_rounded,
                  label: 'Referencia',
                  value:
                      '${notification.referenceType} #${notification.referenceId ?? '-'}',
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
                  value: _paymentMethodLabel(
                    metadata['paymentMethod'] as String,
                  ),
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
              if (action != null) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).pushNamed(action.route);
                    },
                    icon: Icon(action.icon),
                    label: Text(action.label),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

_NotificationAction? _notificationAction(AppNotification notification) {
  return switch (notification.referenceType) {
    'PRODUCT' => const _NotificationAction(
      route: AppRoutes.product,
      label: 'Ver productos',
      icon: Icons.inventory_2_outlined,
    ),
    'CASH_SESSION' => const _NotificationAction(
      route: AppRoutes.cashSession,
      label: 'Revisar caja',
      icon: Icons.point_of_sale_rounded,
    ),
    'INVENTORY_COUNT' => const _NotificationAction(
      route: AppRoutes.inventoryCount,
      label: 'Revisar conteo',
      icon: Icons.fact_check_outlined,
    ),
    _ => null,
  };
}

class _NotificationAction {
  const _NotificationAction({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final IconData icon;
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
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
