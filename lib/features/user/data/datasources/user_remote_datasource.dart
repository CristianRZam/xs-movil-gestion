import 'package:app_movil_sistema/features/user/data/models/user_model.dart';
import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers(UserFilter filter);
  Future<UserFormDataModel> getFormData([int? id]);
  Future<UserModel> create(UserRequest request);
  Future<UserModel> update(UserRequest request);
  Future<void> updateStatus(int id);
}
