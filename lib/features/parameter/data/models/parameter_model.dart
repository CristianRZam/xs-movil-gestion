import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/parameter.dart';
part 'parameter_model.g.dart';

@JsonSerializable()
class ParameterModel extends Parameter {

  const ParameterModel({
    required super.id,
    required super.parameterId,
    super.parentParameterId,
    required super.name,
    required super.shortName,
    required super.active,
  });

  factory ParameterModel.fromJson(
      Map<String, dynamic> json,
      ) => _$ParameterModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ParameterModelToJson(this);

  factory ParameterModel.fromEntity(
      Parameter entity,
      ) {
    return ParameterModel(
      id: entity.id,
      parameterId: entity.parameterId,
      parentParameterId: entity.parentParameterId,
      name: entity.name,
      shortName: entity.shortName,
      active: entity.active,
    );
  }
}