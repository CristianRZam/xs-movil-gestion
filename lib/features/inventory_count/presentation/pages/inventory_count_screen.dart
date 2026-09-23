import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/features/inventory_count/presentation/inventory_count_autofill.dart';
import 'package:app_movil_sistema/features/inventory_movement/presentation/widgets/inventory_count_movement_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
  int? _sessionId;
  DateTime? _openedAt;
  String _stage = 'EMPTY'; // EMPTY, COUNTING, REVIEW, CLOSED
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _feedbackEntry?.remove();
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

  Future<void> _start() => _request(() async {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _adjustments.clear();
    _reasons.clear();
    _suggestedCounts.clear();
    _items = [];
    final session = await _post('/inventory-counts', {});
    _sessionId = (session as Map<String, dynamic>)['id'] as int;
    _stage = 'COUNTING';
    await _loadDetail();
  });

  Future<void> _loadDetail() async {
    final data =
        await _get('/inventory-counts/$_sessionId') as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
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

  Future<void> _review() => _request(() async {
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

  Future<void> _close() => _request(() async {
    final rows = _rows();
    for (final row in rows) {
      if (row['applyAdjustment'] == true &&
          ((row['reason'] as String?)?.trim().isEmpty ?? true)) {
        throw Exception('Indica el motivo para cada ajuste.');
      }
    }
    final result =
        await _put('/inventory-counts/$_sessionId/close', {'items': rows})
            as Map<String, dynamic>;
    _stage = result['status'] == 'CLOSED' ? 'EMPTY' : 'REVIEW';
    if (_stage == 'EMPTY') {
      for (final controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
      _adjustments.clear();
      _reasons.clear();
      _suggestedCounts.clear();
      _items = [];
      _sessionId = null;
      _showFeedback('Conteo finalizado y guardado en el historial.');
    } else {
      _sessionId = result['id'] as int;
    }
    if (mounted) setState(() {});
  });

  Future<void> _confirmClose() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.fact_check_rounded, color: Colors.green),
        title: const Text('¿Validar y finalizar conteo?'),
        content: const Text(
          'Se aplicarán los ajustes seleccionados y la jornada quedará guardada en el historial. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Seguir revisando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sí, finalizar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _close();
  }

  void _editCounts() {
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
    final api = ApiResponse<dynamic>.fromJson(response.data, (v) => v);
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
      _message(
        (e.response?.data as Map?)?['message']?.toString() ??
            'No se pudo procesar el conteo.',
      );
    } catch (e) {
      if (!silent) _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  void _message(String text) {
    _showFeedback(text, isError: true);
  }

  void _showFeedback(String text, {bool isError = false}) {
    if (!mounted) return;

    _feedbackEntry?.remove();
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
        entry.remove();
        _feedbackEntry = null;
      }
    });
  }

  Future<void> _showHistory() async {
    await _request(() async {
      final history = await _get('/inventory-counts') as List<dynamic>;
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) => ListView.builder(
            controller: controller,
            padding: const EdgeInsets.all(20),
            itemCount: history.length + 1,
            itemBuilder: (_, index) {
              if (index == 0)
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Historial de conteos',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                );
              final count = history[index - 1] as Map<String, dynamic>;
              final countNumber = count['countNumber'] as String?;
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.inventory_2_rounded),
                  ),
                  title: Text(countNumber ?? 'Conteo ${count['businessDate']}'),
                  subtitle: Text(
                    'Estado: ${_sessionLabel(count['status'] as String)} • Coinciden: ${count['matchedProducts'] ?? 0}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showHistoryDetail(sheetContext, count['id'] as int),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Future<void> _showHistoryDetail(BuildContext context, int id) async {
    final data = await _get('/inventory-counts/$id') as Map<String, dynamic>;
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
          itemCount: rows.length + 1,
          itemBuilder: (_, index) {
            if (index == 0)
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Detalle del conteo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              );
            final row = rows[index - 1] as Map<String, dynamic>;
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
        IconButton(
          onPressed: _loading ? null : _showHistory,
          icon: const Icon(Icons.history_rounded),
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
          onPressed: _loading ? null : _start,
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _stage == 'REVIEW'
                ? 'Diferencias detectadas: revisa, corrige o aplica ajustes.'
                : 'Completa con el stock actual y corrige solo lo que no coincide físicamente.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, i) => _card(_items[i] as Map<String, dynamic>),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_stage == 'REVIEW')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _editCounts,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar conteos'),
                  ),
                ),
              if (_stage == 'REVIEW') const SizedBox(height: 10),
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
                IconButton(
                  tooltip: 'Ver movimientos',
                  onPressed: _loading ? null : () => _showProductMovements(row),
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
              enabled: _stage == 'COUNTING',
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
              if (status != 'MATCHED')
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aplicar ajuste'),
                  value: _adjustments[id] ?? false,
                  onChanged: (v) => setState(() => _adjustments[id] = v),
                ),
              if (_adjustments[id] ?? false)
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
