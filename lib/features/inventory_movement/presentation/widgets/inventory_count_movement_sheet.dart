import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showInventoryCountMovementSheet({
  required BuildContext context,
  required String productName,
  required List<InventoryMovementDetail> movements,
  DateTime? countOpenedAt,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      minChildSize: .45,
      maxChildSize: .92,
      builder: (context, controller) => _InventoryCountMovementSheet(
        productName: productName,
        movements: movements,
        countOpenedAt: countOpenedAt,
        scrollController: controller,
      ),
    ),
  );
}

class _InventoryCountMovementSheet extends StatelessWidget {
  const _InventoryCountMovementSheet({
    required this.productName,
    required this.movements,
    required this.countOpenedAt,
    required this.scrollController,
  });

  final String productName;
  final List<InventoryMovementDetail> movements;
  final DateTime? countOpenedAt;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final duringCount = movements.where(_occurredDuringCount).length;

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
                      Text(productName),
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
          if (countOpenedAt != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text('$duringCount movimiento(s) desde el inicio'),
                ),
              ),
            ),
          const Divider(),
          Expanded(
            child: movements.isEmpty
                ? const Center(
                    child: Text('Este producto todavía no tiene movimientos.'),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: movements.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => _MovementTile(
                      movement: movements[index],
                      occurredDuringCount: _occurredDuringCount(movements[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool _occurredDuringCount(InventoryMovementDetail movement) {
    return countOpenedAt != null && !movement.createdAt.isBefore(countOpenedAt!);
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

  String _quantityText(InventoryMovementDetail movement) {
    if (movement.type == 'ADJUSTMENT') {
      return '${_number(movement.previousStock)} → ${_number(movement.currentStock)}';
    }
    final prefix = {'SALE', 'WASTE'}.contains(movement.type) ? '-' : '+';
    return '$prefix${_number(movement.quantity)}';
  }

  String _number(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}

_MovementMetadata _movementMetadata(String type) {
  return switch (type) {
    'ENTRY' => const _MovementMetadata('Entrada', Icons.add_box_rounded, Colors.green),
    'SALE' => const _MovementMetadata('Venta', Icons.shopping_bag_rounded, Colors.blue),
    'WASTE' => const _MovementMetadata('Merma', Icons.delete_outline_rounded, Colors.red),
    'SALE_RETURN' => const _MovementMetadata('Devolución', Icons.assignment_return_rounded, Colors.deepPurple),
    'ADJUSTMENT' => const _MovementMetadata('Ajuste', Icons.tune_rounded, Colors.orange),
    _ => const _MovementMetadata('Movimiento', Icons.history_rounded, Colors.grey),
  };
}

class _MovementMetadata {
  const _MovementMetadata(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
