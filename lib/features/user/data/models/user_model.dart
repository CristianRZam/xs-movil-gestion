import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.active,
    required super.fullName,
    required super.document,
    required super.typeDocument,
    required super.phone,
    required super.address,
    required super.roleIds,
    required super.roleNames,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? const {};
    final roles = json['userRoles'] as List<dynamic>? ?? const [];
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      fullName: person['fullName'] as String? ?? '',
      document: person['document'] as String? ?? '',
      typeDocument: (person['typeDocument'] as num?)?.toInt(),
      phone: person['phone'] as String?,
      address: person['address'] as String?,
      roleIds: roles
          .map(
            (e) =>
                ((e as Map<String, dynamic>)['role']
                    as Map<String, dynamic>?)?['id'],
          )
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(),
      roleNames: roles
          .map(
            (e) =>
                (((e as Map<String, dynamic>)['role']
                        as Map<String, dynamic>?)?['name']
                    as String? ??
                ''),
          )
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }
  AppUser toEntity() => AppUser(
    id: id,
    username: username,
    email: email,
    active: active,
    fullName: fullName,
    document: document,
    typeDocument: typeDocument,
    phone: phone,
    address: address,
    roleIds: roleIds,
    roleNames: roleNames,
  );
}

class UserFormDataModel extends UserFormData {
  const UserFormDataModel({
    required super.documentTypes,
    required super.roles,
    super.user,
  });
  factory UserFormDataModel.fromJson(Map<String, dynamic> json) =>
      UserFormDataModel(
        user: json['user'] is Map<String, dynamic>
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        documentTypes: _options(json['documentTypes']),
        roles: _options(json['roles']),
      );
  static List<UserOption> _options(Object? raw) =>
      (raw as List<dynamic>? ?? const [])
          .map((e) {
            final item = e as Map<String, dynamic>;
            return UserOption(
              id:
                  (item['parameterId'] ?? item['id'] as num?) as int? ??
                  ((item['id'] as num?)?.toInt() ?? 0),
              name: item['name'] as String? ?? '',
              active: item['active'] as bool? ?? true,
            );
          })
          .where((e) => e.id > 0)
          .toList();
  UserFormData toEntity() =>
      UserFormData(documentTypes: documentTypes, roles: roles, user: user);
}
