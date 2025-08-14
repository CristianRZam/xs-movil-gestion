import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_response.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({required String token}) : super(token: token);

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
