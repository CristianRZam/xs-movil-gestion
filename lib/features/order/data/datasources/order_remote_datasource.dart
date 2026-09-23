import 'package:app_movil_sistema/features/order/data/models/order_model.dart';
import 'package:app_movil_sistema/features/order/data/models/order_page_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderPageModel> getAll({
    int page = 0,
    int size = 20,
    DateTime? from,
    DateTime? to,
  });
  Future<OrderModel> create(OrderModel order);
  Future<OrderModel> update(int id, OrderModel order);
  Future<OrderModel> updateStatus(int id, String status);
  Future<bool> delete(int id);
}
