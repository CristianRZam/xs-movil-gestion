class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.active,
    required this.fullName,
    required this.document,
    required this.typeDocument,
    required this.phone,
    required this.address,
    required this.roleIds,
    required this.roleNames,
  });
  final int id;
  final String username;
  final String email;
  final bool active;
  final String fullName;
  final String document;
  final int? typeDocument;
  final String? phone;
  final String? address;
  final List<int> roleIds;
  final List<String> roleNames;
}

class UserOption {
  const UserOption({required this.id, required this.name, this.active = true});
  final int id;
  final String name;
  final bool active;
}

class UserFormData {
  const UserFormData({
    required this.documentTypes,
    required this.roles,
    this.user,
  });
  final List<UserOption> documentTypes;
  final List<UserOption> roles;
  final AppUser? user;
}

class UserRequest {
  const UserRequest({
    this.id,
    required this.username,
    required this.email,
    required this.typeDocument,
    required this.document,
    required this.fullName,
    this.phone,
    this.address,
    required this.roleIds,
  });
  final int? id;
  final String username;
  final String email;
  final int typeDocument;
  final String document;
  final String fullName;
  final String? phone;
  final String? address;
  final List<int> roleIds;
}

class UserFilter {
  const UserFilter({
    this.query,
    this.status,
    this.typeDocument,
    this.page = 0,
    this.size = 20,
  });
  final String? query;
  final bool? status;
  final int? typeDocument;
  final int page;
  final int size;
}
