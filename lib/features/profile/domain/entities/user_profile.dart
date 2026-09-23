class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.document,
    this.documentTypeName,
    this.phone,
    this.address,
    this.avatarUrl,
    this.roles = const [],
  });

  final int id;
  final String email;
  final String? fullName;
  final String? document;
  final String? documentTypeName;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final List<String> roles;
}
