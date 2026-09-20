import 'package:app_movil_sistema/features/parameter/data/models/parameter_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_model.dart';

import '../../domain/entities/product_view_response.dart';

class ProductViewResponseModel extends ProductViewResponse {
  ProductViewResponseModel({
    required super.products,
    required super.totalProducts,
    required super.activeProducts,
    required super.inactiveProducts,
    required super.totalStock,
    required super.categories,
    required super.unitMeasures,
    required super.valuationMethods,
  });

  factory ProductViewResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductViewResponseModel(
      products: (json['products'] as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),

      totalProducts: json['totalProducts'] as int,
      activeProducts: json['activeProducts'] as int,
      inactiveProducts: json['inactiveProducts'] as int,
      totalStock: json['totalStock'] as int,

      categories: (json['categories'] as List)
          .map((e) => ParameterModel.fromJson(e as Map<String, dynamic>)).toList(),

      unitMeasures: (json['unitMeasures'] as List)
          .map((e) => ParameterModel.fromJson(e as Map<String, dynamic>)).toList(),

      valuationMethods: (json['valuationMethods'] as List)
          .map((e) => ParameterModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}