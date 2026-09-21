import 'package:app_movil_sistema/features/order/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getAll();
  Future<OrderModel> create(OrderModel order);
  Future<OrderModel> update(int id, OrderModel order);
  Future<OrderModel> updateStatus(int id, String status);
  Future<bool> delete(int id);
}
