import 'package:app_movil_sistema/features/inventory_count/domain/entities/inventory_count.dart';
abstract class InventoryCountRemoteDataSource { Future<InventoryCount?> current(); Future<InventoryCount> open(); Future<List<InventoryCountItem>> detail(int id); Future<InventoryCount> close(int id,List<InventoryCountEntry> items); }
