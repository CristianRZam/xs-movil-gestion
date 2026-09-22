import 'package:app_movil_sistema/features/inventory_count/domain/entities/inventory_count.dart';

abstract class InventoryCountEvent {
  const InventoryCountEvent();
}

class LoadInventoryCount extends InventoryCountEvent {
  const LoadInventoryCount();
}

class StartInventoryCount extends InventoryCountEvent {
  const StartInventoryCount();
}

class FinishInventoryCount extends InventoryCountEvent {
  final List<InventoryCountEntry> items;
  const FinishInventoryCount(this.items);
}
