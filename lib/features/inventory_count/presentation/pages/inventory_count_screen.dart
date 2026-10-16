import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:app_movil_sistema/features/inventory_count/presentation/inventory_count_autofill.dart';
import 'package:app_movil_sistema/features/inventory_movement/presentation/widgets/inventory_count_movement_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryCountScreen extends StatefulWidget {
  const InventoryCountScreen({super.key});
  @override
  State<InventoryCountScreen> createState() => _InventoryCountScreenState();
}

class _InventoryCountScreenState extends State<InventoryCountScreen> {
  final _api = ApiClient();
  final _controllers = <int, TextEditingController>{};
  final _adjustments = <int, bool>{};
  final _reasons = <int, String>{};
  final _suggestedCounts = <int>{};
  OverlayEntry? _feedbackEntry;
  List<dynamic> _items = [];
  Map<String, dynamic>? _session;
  int? _sessionId;
  DateTime? _openedAt;
  String _stage = 'EMPTY'; // EMPTY, COUNTING, REVIEW, CLOSED
  bool _loading = false;

  bool _allows(AppCapability capability) =>
      getIt<AccessControl>().allows(capability);

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _removeFeedback();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _restore() async {
    await _request(() async {
      final current = await _get('/inventory-counts/current');
      if (current == null) return;
      _sessionId = (current as Map<String, dynamic>)['id'] as int;
      _stage = (current['status'] as String) == 'REVIEW'
          ? 'REVIEW'
          : 'COUNTING';
      await _loadDetail();
    }, silent: true);
  }

  Future<void> _start() {
    if (!_allows(AppCapability.createInventoryCount)) return Future.value();
    return _request(() async {
      for (final controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
      _adjustments.clear();
      _reasons.clear();
      _suggestedCounts.clear();
      _items = [];
      _session = null;
      final session = await _post('/inventory-counts', {});
      _sessionId = (session as Map<String, dynamic>)['id'] as int;
      _stage = 'COUNTING';
      await _loadDetail();
      _showFeedback(
        'El conteo se inició correctamente.',
        successTitle: 'Conteo iniciado',
      );
    });
  }

  Future<void> _loadDetail() async {
    final data =
        await _get('/inventory-counts/$_sessionId') as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    _session = session;
    _openedAt = DateTime.tryParse(session['openedAt']?.toString() ?? '');
    _items = data['items'] as List<dynamic>;
    for (final row in _items) {
      final item = row['item'] as Map<String, dynamic>;
      final id = item['productId'] as int;
      _controllers.putIfAbsent(
        id,
        () => TextEditingController(
          text: item['physicalStock']?.toString() ?? '',
        ),
      );
    }
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> _rows() => _items
      .where((row) {
        final id = (row['item'] as Map<String, dynamic>)['productId'] as int;
        return int.tryParse(_controllers[id]!.text) != null;
      })
      .map((row) {
        final id = (row['item'] as Map<String, dynamic>)['productId'] as int;
        return {
          'productId': id,
          'physicalStock': int.parse(_controllers[id]!.text),
          'applyAdjustment': _adjustments[id] ?? false,
          'reason': _reasons[id],
        };
      })
      .toList();

  int _fillBlankCountsWithCurrentStock() {
    final currentValues = <int, String>{
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
    final expectedStocks = <int, int>{
      for (final row in _items)
        (row['item'] as Map<String, dynamic>)['productId'] as int:
            (row['currentStock'] as num?)?.toInt() ?? 0,
    };
    final suggestions = InventoryCountAutofill.blankFieldsWithExpectedStock(
      currentValues,
      expectedStocks,
    );

    if (suggestions.isEmpty) {
      return 0;
    }

    setState(() {
      for (final entry in suggestions.entries) {
        _controllers[entry.key]!.text = entry.value;
        _suggestedCounts.add(entry.key);
      }
    });

    return suggestions.length;
  }

  Future<void> _review() {
    if (!_allows(AppCapability.reviewInventoryCount)) return Future.value();
    return _request(() async {
      await _loadDetail();
      final filled = _fillBlankCountsWithCurrentStock();
      final rows = _rows();
      if (rows.isEmpty) {
        throw Exception('Registra el conteo físico de al menos un producto.');
      }
      await _put('/inventory-counts/$_sessionId/review', {'items': rows});
      _stage = 'REVIEW';
      await _loadDetail();
      _showFeedback(
        filled > 0
            ? 'Se completaron $filled campos vacíos y se validó el conteo.'
            : 'Conteo validado. Revisa las diferencias antes de cerrar.',
      );
    });
  }

  Future<void> _close(String? closingComment) {
    if (!_allows(AppCapability.closeInventoryCount)) return Future.value();
    return _request(() async {
      final rows = _rows();
      for (final row in rows) {
        if (row['applyAdjustment'] == true &&
            ((row['reason'] as String?)?.trim().isEmpty ?? true)) {
          throw Exception('Indica el motivo para cada ajuste.');
        }
      }
      final request = <String, dynamic>{'items': rows};
      if (closingComment != null && closingComment.trim().isNotEmpty) {
        request['closingComment'] = closingComment.trim();
      }
      final result =
          await _put('/inventory-counts/$_sessionId/close', request)
              as Map<String, dynamic>;
      for (final controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
      _adjustments.clear();
      _reasons.clear();
      _suggestedCounts.clear();
      _items = [];
      _session = null;
      _sessionId = result['id'] as int;
      _stage = 'COUNTING';
      await _loadDetail();
      _showFeedback(
        'El conteo finalizó y el siguiente ya está listo para registrar.',
        successTitle: 'Conteo finalizado',
      );
    });
  }

  Future<void> _confirmClose() async {
    if (!_allows(AppCapability.closeInventoryCount)) return;
    final closingCommentController = TextEditingController();
    final closingComment = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.fact_check_rounded, color: Colors.green),
        title: const Text('¿Validar y finalizar conteo?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Se aplicarán los ajustes seleccionados y la jornada quedará guardada en el historial. Esta acción no se puede deshacer.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: closingCommentController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentario de cierre (opcional)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.comment_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Seguir revisando'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, closingCommentController.text),
            child: const Text('Sí, finalizar'),
          ),
        ],
      ),
    );
    // La ruta del diálogo puede seguir reconstruyéndose durante su animación
    // de salida; liberar el controlador inmediatamente provoca que el campo
    // intente usarlo después de dispose.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    closingCommentController.dispose();
    if (closingComment != null && mounted) await _close(closingComment);
  }

  void _editCounts() {
    if (!_allows(AppCapability.reviewInventoryCount)) return;
    setState(() {
      _stage = 'COUNTING';
      _adjustments.clear();
      _reasons.clear();
      _suggestedCounts.clear();
    });
    _showFeedback('Puedes corregir los conteos y validarlos nuevamente.');
  }

  Future<void> _showProductMovements(Map<String, dynamic> row) =>
      _request(() async {
        final item = row['item'] as Map<String, dynamic>;
        await showInventoryCountMovementSheet(
          context: context,
          productId: item['productId'] as int,
          productName: row['productName'] as String,
          countOpenedAt: _openedAt,
        );
      });

  Future<dynamic> _get(String path) async {
    final r = await _api.dio.get(path);
    return _data(r);
  }

  Future<dynamic> _post(String path, Object body) async {
    final r = await _api.dio.post(path, data: body);
    return _data(r);
  }

  Future<dynamic> _put(String path, Object body) async {
    final r = await _api.dio.put(path, data: body);
    return _data(r);
  }

  dynamic _data(Response response) {
    final payload = response.data;
    if (payload is! Map) {
      throw Exception('La respuesta del servidor no tiene un formato válido.');
    }
    final api = ApiResponse<dynamic>.fromJson(
      Map<String, dynamic>.from(payload),
      (v) => v,
    );
    if (!api.success) throw Exception(api.message);
    return api.data;
  }

  Future<void> _request(
    Future<void> Function() action, {
    bool silent = false,
  }) async {
    if (!silent) setState(() => _loading = true);
    try {
      await action();
    } on DioException catch (e) {
      _message(_dioErrorMessage(e));
    } catch (e) {
      if (!silent) _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  String _dioErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return 'No se pudo procesar el conteo.';
  }

  void _message(String text) {
    _showFeedback(text, isError: true);
  }

  void _showFeedback(
    String text, {
    bool isError = false,
    String successTitle = 'Conteo actualizado',
  }) {
    if (!mounted) return;

    if (!isError) {
      _removeFeedback();
      FlashMessage.show(
        context,
        type: FlashMessageType.success,
        title: successTitle,
        message: text,
      );
      return;
    }

    _removeFeedback();
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + 12,
        left: 16,
        right: 16,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isError
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: isError
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isError
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _feedbackEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (_feedbackEntry == entry) {
        _removeFeedback();
      }
    });
  }

  void _removeFeedback() {
    final entry = _feedbackEntry;
    _feedbackEntry = null;
    if (entry?.mounted ?? false) {
      entry!.remove();
    }
  }

  Future<void> _showHistory() async {
    if (!_allows(AppCapability.viewInventoryCountHistory)) return;
    await _request(() async {
      final firstPage =
          await _get(
                '/inventory-counts?page=0&limit=${EnvConfig.inventoryCountHistoryLimit}',
              )
              as Map<String, dynamic>;
      final history = List<dynamic>.from(
        firstPage['items'] as List? ?? const [],
      );
      var currentPage = (firstPage['page'] as num?)?.toInt() ?? 0;
      var hasMore = firstPage['hasMore'] == true;
      var loadingMore = false;
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) => DraggableScrollableSheet(
            expand: false,
            builder: (_, controller) => ListView.builder(
              controller: controller,
              padding: const EdgeInsets.all(20),
              itemCount: history.length + 1 + (hasMore || loadingMore ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Historial de conteos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                if (index == history.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: loadingMore
                            ? null
                            : () async {
                                setSheetState(() => loadingMore = true);
                                try {
                                  final nextPage =
                                      await _get(
                                            '/inventory-counts?page=${currentPage + 1}&limit=${EnvConfig.inventoryCountHistoryLimit}',
                                          )
                                          as Map<String, dynamic>;
                                  if (!sheetContext.mounted) return;
                                  setSheetState(() {
                                    history.addAll(
                                      List<dynamic>.from(
                                        nextPage['items'] as List? ?? const [],
                                      ),
                                    );
                                    currentPage =
                                        (nextPage['page'] as num?)?.toInt() ??
                                        currentPage + 1;
                                    hasMore = nextPage['hasMore'] == true;
                                    loadingMore = false;
                                  });
                                } on DioException catch (error) {
                                  if (sheetContext.mounted) {
                                    setSheetState(() => loadingMore = false);
                                  }
                                  _message(_dioErrorMessage(error));
                                } catch (_) {
                                  if (sheetContext.mounted) {
                                    setSheetState(() => loadingMore = false);
                                  }
                                  _message('No se pudo cargar más conteos.');
                                }
                              },
                        icon: loadingMore
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more_rounded),
                        label: Text(
                          loadingMore ? 'Cargando...' : 'Ver más conteos',
                        ),
                      ),
                    ),
                  );
                }
                final count = history[index - 1] as Map<String, dynamic>;
                final countNumber = count['countNumber'] as String?;
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.inventory_2_rounded),
                    ),
                    title: Text(
                      countNumber ?? 'Conteo ${count['businessDate']}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado: ${_sessionLabel(count['status'] as String)} • Coinciden: ${count['matchedProducts'] ?? 0}',
                        ),
                        const SizedBox(height: 3),
                        Text(
                          count['closedAt'] == null
                              ? 'Aún sin cerrar'
                              : 'Cerrado: ${_formatAuditDate(count['closedAt'])}',
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showHistoryDetail(sheetContext, count['id'] as int),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showHistoryDetail(BuildContext context, int id) async {
    if (!_allows(AppCapability.viewInventoryCountHistory)) return;
    final data = await _get('/inventory-counts/$id') as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    final rows = data['items'] as List<dynamic>;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          padding: const EdgeInsets.all(20),
          itemCount: rows.length + 2,
          itemBuilder: (_, index) {
            if (index == 0)
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Detalle del conteo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              );
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _sessionAuditCard(session, items: rows),
              );
            }
            final row = rows[index - 2] as Map<String, dynamic>;
            final item = row['item'] as Map<String, dynamic>;
            return ListTile(
              title: Text(row['productName'] as String),
              subtitle: Text(
                'Esperado: ${item['expectedStock'] ?? '-'} • Físico: ${item['physicalStock'] ?? '-'}',
              ),
              trailing: Text(_resultLabel(item['resultStatus'] as String?)),
            );
          },
        ),
      ),
    );
  }

  Widget _sessionAuditCard(
    Map<String, dynamic> session, {
    required List<dynamic> items,
    bool compact = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isClosed = session['closedAt'] != null;
    final stats = _countStats(items);
    final openingComment = session['openingComment']?.toString().trim();
    final closingComment = session['closingComment']?.toString().trim();
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerLow : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(isDark ? .28 : .10),
            blurRadius: isDark ? 18 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: scheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  session['countNumber']?.toString() ?? 'Sesión de conteo',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              _statusChip(session['status']?.toString()),
            ],
          ),
          const SizedBox(height: 14),
          _countSummary(stats, isClosed: isClosed),
          const SizedBox(height: 16),
          _auditRow(
            Icons.lock_open_rounded,
            scheme.onSurfaceVariant,
            'Apertura',
            '${_auditUser(session['openedByName'])} · ${_formatAuditDate(session['openedAt'])}',
          ),
          if (openingComment?.isNotEmpty == true)
            _auditRow(
              Icons.auto_awesome_rounded,
              scheme.onSurfaceVariant,
              'Observación de apertura',
              openingComment!,
            ),
          const Divider(height: 22),
          _auditRow(
            isClosed ? Icons.lock_rounded : Icons.lock_clock_rounded,
            scheme.onSurfaceVariant,
            'Cierre',
            isClosed
                ? '${_auditUser(session['closedByName'])} · ${_formatAuditDate(session['closedAt'])}'
                : 'Conteo en curso',
          ),
          if (closingComment?.isNotEmpty == true)
            _auditRow(
              Icons.comment_rounded,
              scheme.onSurfaceVariant,
              'Comentario de cierre',
              closingComment!,
            ),
        ],
      ),
    );
  }

  Map<String, int> _countStats(List<dynamic> items) {
    var matched = 0;
    var shortage = 0;
    var surplus = 0;
    var pending = 0;
    for (final row in items) {
      final item =
          (row as Map<String, dynamic>)['item'] as Map<String, dynamic>;
      switch (item['resultStatus']) {
        case 'MATCHED':
          matched++;
          break;
        case 'SHORTAGE':
          shortage++;
          break;
        case 'SURPLUS':
          surplus++;
          break;
        default:
          pending++;
      }
    }
    return {
      'total': items.length,
      'matched': matched,
      'shortage': shortage,
      'surplus': surplus,
      'pending': pending,
    };
  }

  Widget _countSummary(Map<String, int> stats, {required bool isClosed}) {
    final scheme = Theme.of(context).colorScheme;
    final pending = stats['pending'] ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isClosed ? Icons.bar_chart_rounded : Icons.inventory_2_outlined,
                color: scheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isClosed ? 'Resultado final del conteo' : 'Avance del conteo',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${stats['total'] ?? 0} productos',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (_, constraints) {
              final metricWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _countMetric(
                    width: metricWidth,
                    label: 'Coinciden',
                    value: stats['matched'] ?? 0,
                    color: scheme.onSurface,
                  ),
                  _countMetric(
                    width: metricWidth,
                    label: 'Faltantes',
                    value: stats['shortage'] ?? 0,
                    color: scheme.error,
                  ),
                  _countMetric(
                    width: metricWidth,
                    label: 'Sobrantes',
                    value: stats['surplus'] ?? 0,
                    color: scheme.onSurfaceVariant,
                  ),
                  if (pending > 0)
                    _countMetric(
                      width: metricWidth,
                      label: 'Pendientes',
                      value: pending,
                      color: scheme.outline,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _countMetric({
    required double width,
    required String label,
    required int value,
    required Color color,
  }) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );

  Widget _auditRow(IconData icon, Color color, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _statusChip(String? status) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _sessionLabel(status ?? ''),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _auditUser(Object? value) {
    final name = value?.toString().trim() ?? '';
    return name.isEmpty ? 'Sin registro' : name;
  }

  String _formatAuditDate(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null
        ? 'Sin registro'
        : DateFormat('dd/MM/yyyy · HH:mm').format(date);
  }

  String _sessionLabel(String value) =>
      const {
        'OPEN': 'Abierto',
        'REVIEW': 'En revisión',
        'CLOSED': 'Finalizado',
        'CANCELLED': 'Cancelado',
      }[value] ??
      value;

  String _resultLabel(String? value) =>
      const {
        'MATCHED': 'Coincide',
        'SHORTAGE': 'Faltante',
        'SURPLUS': 'Sobrante',
        'PENDING': 'Pendiente',
      }[value] ??
      'Pendiente';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: XsAppBar(
      title: 'Conteo diario',
      backIcon: false,
      actions: [
        if (_allows(AppCapability.viewInventoryCountHistory))
          IconButton(
            onPressed: _loading ? null : _showHistory,
            icon: const Icon(Icons.history_rounded, color: Colors.white),
          ),
      ],
    ),
    endDrawer: const XsDrawer(),
    body: Stack(
      children: [
        _body(),
        if (_loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    ),
  );
  Widget _body() {
    if (_stage == 'EMPTY')
      return Center(
        child: FilledButton.icon(
          onPressed: _loading || !_allows(AppCapability.createInventoryCount)
              ? null
              : _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Iniciar conteo'),
        ),
      );
    if (_stage == 'CLOSED')
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, color: Colors.green, size: 64),
            SizedBox(height: 12),
            Text(
              'Conteo finalizado',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('La jornada quedó guardada en el historial.'),
          ],
        ),
      );
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(
                  _stage == 'REVIEW'
                      ? 'Diferencias detectadas: revisa, corrige o aplica ajustes.'
                      : 'Completa con el stock actual y corrige solo lo que no coincide físicamente.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (_session != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _sessionAuditCard(
                    _session!,
                    items: _items,
                    compact: true,
                  ),
                ),
              ..._items.map((row) => _card(row as Map<String, dynamic>)),
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_stage == 'REVIEW' &&
                    _allows(AppCapability.reviewInventoryCount))
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _editCounts,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar conteos'),
                    ),
                  ),
                if (_stage == 'REVIEW' &&
                    _allows(AppCapability.reviewInventoryCount))
                  const SizedBox(height: 10),
                if ((_stage == 'COUNTING' &&
                        _allows(AppCapability.reviewInventoryCount)) ||
                    (_stage == 'REVIEW' &&
                        _allows(AppCapability.closeInventoryCount)))
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading
                          ? null
                          : (_stage == 'COUNTING' ? _review : _confirmClose),
                      icon: Icon(
                        _stage == 'COUNTING'
                            ? Icons.rule_rounded
                            : Icons.task_alt_rounded,
                      ),
                      label: Text(
                        _stage == 'COUNTING'
                            ? 'Validar conteo'
                            : 'Validar y finalizar conteo',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(Map<String, dynamic> row) {
    final item = row['item'] as Map<String, dynamic>;
    final id = item['productId'] as int;
    final diff = (item['difference'] as num?)?.toInt();
    final status = item['resultStatus'] as String?;
    final color = status == 'MATCHED'
        ? Colors.green
        : status == 'SHORTAGE'
        ? Colors.red
        : Colors.orange;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row['productName'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_allows(AppCapability.viewProductMovements))
                  IconButton(
                    tooltip: 'Ver movimientos',
                    onPressed: _loading
                        ? null
                        : () => _showProductMovements(row),
                    icon: const Icon(Icons.swap_horiz_rounded),
                  ),
              ],
            ),
            Text('Inicial: ${item['openingStock']} und.'),
            if (_stage == 'COUNTING')
              Text(
                'Stock actual: ${row['currentStock'] ?? 0} und.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            TextField(
              controller: _controllers[id],
              enabled:
                  _stage == 'COUNTING' &&
                  _allows(AppCapability.reviewInventoryCount),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (_suggestedCounts.contains(id) && mounted) {
                  setState(() {
                    _suggestedCounts.remove(id);
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Conteo físico',
                helperText: _suggestedCounts.contains(id)
                    ? 'Valor sugerido: verifica el stock físico.'
                    : null,
                suffixIcon: _suggestedCounts.contains(id)
                    ? const Icon(Icons.auto_fix_high_rounded)
                    : null,
              ),
            ),
            if (_stage == 'REVIEW') ...[
              Chip(
                label: Text(
                  status == 'MATCHED'
                      ? 'Coincide'
                      : status == 'SHORTAGE'
                      ? 'Faltante: $diff'
                      : 'Sobrante: +$diff',
                ),
                backgroundColor: color.withOpacity(.12),
              ),
              if (status != 'MATCHED' &&
                  _allows(AppCapability.closeInventoryCount))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aplicar ajuste'),
                  value: _adjustments[id] ?? false,
                  onChanged: (v) => setState(() => _adjustments[id] = v),
                ),
              if ((_adjustments[id] ?? false) &&
                  _allows(AppCapability.closeInventoryCount))
                TextField(
                  onChanged: (v) => _reasons[id] = v,
                  decoration: const InputDecoration(
                    labelText: 'Motivo del ajuste',
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
