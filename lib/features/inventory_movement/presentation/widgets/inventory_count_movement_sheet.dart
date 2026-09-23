import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_detail.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/usecases/get_inventory_movements_usecase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showInventoryCountMovementSheet({
  required BuildContext context,
  required int productId,
  required String productName,
  DateTime? countOpenedAt,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: .72,
    minChildSize: .45,
    maxChildSize: .92,
    builder: (context, controller) => _InventoryMovementSheet(
      productId: productId,
      productName: productName,
      countOpenedAt: countOpenedAt,
      scrollController: controller,
    ),
  ),
);

class _InventoryMovementSheet extends StatefulWidget {
  const _InventoryMovementSheet({
    required this.productId,
    required this.productName,
    required this.countOpenedAt,
    required this.scrollController,
  });
  final int productId;
  final String productName;
  final DateTime? countOpenedAt;
  final ScrollController scrollController;
  @override
  State<_InventoryMovementSheet> createState() =>
      _InventoryMovementSheetState();
}

class _InventoryMovementSheetState extends State<_InventoryMovementSheet> {
  final _useCase = getIt<GetInventoryMovementsUseCase>();
  final List<InventoryMovementDetail> _movements = [];
  bool _loading = true, _loadingMore = false, _hasMore = false;
  int _page = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final result = await _useCase(
      widget.productId,
      page: 0,
      size: EnvConfig.inventoryMovementPageSize,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loading = false;
      }),
      (data) => setState(() {
        _movements.addAll(data.movements);
        _hasMore = data.hasMore;
        _page = data.page;
        _loading = false;
      }),
    );
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final result = await _useCase(
      widget.productId,
      page: _page + 1,
      size: EnvConfig.inventoryMovementPageSize,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loadingMore = false;
      }),
      (data) => setState(() {
        _movements.addAll(data.movements);
        _hasMore = data.hasMore;
        _page = data.page;
        _loadingMore = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duringCount = _movements
        .where(
          (m) =>
              widget.countOpenedAt != null &&
              !m.createdAt.isBefore(widget.countOpenedAt!),
        )
        .length;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.swap_horiz_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movimientos del producto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(widget.productName),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          if (widget.countOpenedAt != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(
                    '$duringCount movimiento(s) cargados desde el inicio',
                  ),
                ),
              ),
            ),
          const Divider(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _movements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_movements.isEmpty) {
      return const Center(
        child: Text('Este producto todavía no tiene movimientos.'),
      );
    }
    return ListView.separated(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _movements.length + (_hasMore || _loadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        if (index == _movements.length) {
          return Center(
            child: _loadingMore
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  )
                : OutlinedButton.icon(
                    onPressed: _loadMore,
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('Ver más movimientos'),
                  ),
          );
        }
        final movement = _movements[index];
        final during =
            widget.countOpenedAt != null &&
            !movement.createdAt.isBefore(widget.countOpenedAt!);
        return _MovementTile(movement: movement, occurredDuringCount: during);
      },
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({
    required this.movement,
    required this.occurredDuringCount,
  });
  final InventoryMovementDetail movement;
  final bool occurredDuringCount;
  @override
  Widget build(BuildContext context) {
    final metadata = _movementMetadata(movement.type);
    final quantity = _quantityText(movement);
    return Card(
      elevation: 0,
      color: occurredDuringCount
          ? metadata.color.withValues(alpha: .10)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: metadata.color.withValues(alpha: .18),
          child: Icon(metadata.icon, color: metadata.color),
        ),
        title: Row(
          children: [
            Expanded(child: Text(metadata.label)),
            Text(quantity, style: TextStyle(color: metadata.color)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${DateFormat('dd/MM/yyyy HH:mm').format(movement.createdAt)} · ${movement.createdBy}',
            ),
            Text(
              'Stock: ${_number(movement.previousStock)} → ${_number(movement.currentStock)}',
            ),
            if (movement.reason?.trim().isNotEmpty ?? false)
              Text('Motivo: ${movement.reason}'),
            if (occurredDuringCount)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Durante este conteo'),
              ),
          ],
        ),
      ),
    );
  }

  String _quantityText(InventoryMovementDetail movement) =>
      movement.type == 'ADJUSTMENT'
      ? '${_number(movement.previousStock)} → ${_number(movement.currentStock)}'
      : '${{'SALE', 'WASTE'}.contains(movement.type) ? '-' : '+'}${_number(movement.quantity)}';
  String _number(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toString();
}

_MovementMetadata _movementMetadata(String type) => switch (type) {
  'ENTRY' => const _MovementMetadata(
    'Entrada',
    Icons.add_box_rounded,
    Colors.green,
  ),
  'SALE' => const _MovementMetadata(
    'Venta',
    Icons.shopping_bag_rounded,
    Colors.blue,
  ),
  'WASTE' => const _MovementMetadata(
    'Merma',
    Icons.delete_outline_rounded,
    Colors.red,
  ),
  'SALE_RETURN' => const _MovementMetadata(
    'Devolución',
    Icons.assignment_return_rounded,
    Colors.deepPurple,
  ),
  'ADJUSTMENT' => const _MovementMetadata(
    'Ajuste',
    Icons.tune_rounded,
    Colors.orange,
  ),
  _ => const _MovementMetadata(
    'Movimiento',
    Icons.history_rounded,
    Colors.grey,
  ),
};

class _MovementMetadata {
  const _MovementMetadata(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
