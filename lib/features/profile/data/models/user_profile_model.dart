import 'package:app_movil_sistema/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.fullName,
    super.document,
    super.documentTypeName,
    super.phone,
    super.address,
    super.avatarUrl,
    super.roles,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? const {};
    return UserProfileModel(
      id: (json['idUser'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      fullName: person['fullName'] as String?,
      document: person['document'] as String?,
      documentTypeName: person['typeDocumentName'] as String?,
      phone: person['phone'] as String?,
      address: person['address'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}
