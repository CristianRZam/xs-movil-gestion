// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParameterModel _$ParameterModelFromJson(Map<String, dynamic> json) =>
    ParameterModel(
      id: (json['id'] as num).toInt(),
      parameterId: (json['parameterId'] as num).toInt(),
      parentParameterId: (json['parentParameterId'] as num?)?.toInt(),
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$ParameterModelToJson(ParameterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parameterId': instance.parameterId,
      'parentParameterId': instance.parentParameterId,
      'name': instance.name,
      'shortName': instance.shortName,
      'active': instance.active,
    };
