import 'inventory_movement_detail.dart';

class InventoryMovementPage {
  const InventoryMovementPage({
    required this.movements,
    required this.totalElements,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  final List<InventoryMovementDetail> movements;
  final int totalElements;
  final int page;
  final int size;
  final bool hasMore;
}
