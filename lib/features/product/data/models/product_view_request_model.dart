import '../../domain/entities/product_view_request.dart';

class ProductViewRequestModel extends ProductViewRequest {

  const ProductViewRequestModel({
    super.code,
    super.name,
    super.description,
    super.categories,
    super.unitMeasures,
    super.valuationMethods,
    super.manageVariant,
    super.minimumStock,
    super.maximumStock,
    super.status,
    super.page,
    super.size,
  });


  factory ProductViewRequestModel.fromEntity(
      ProductViewRequest entity,
      ) {

    return ProductViewRequestModel(
      code: entity.code,
      name: entity.name,
      description: entity.description,
      categories: entity.categories,
      unitMeasures: entity.unitMeasures,
      valuationMethods: entity.valuationMethods,
      manageVariant: entity.manageVariant,
      minimumStock: entity.minimumStock,
      maximumStock: entity.maximumStock,
      status: entity.status,
      page: entity.page,
      size: entity.size,
    );

  }


  Map<String, dynamic> toJson() {

    return {
      'code': code,
      'name': name,
      'description': description,
      'categories': categories,
      'unitMeasures': unitMeasures,
      'valuationMethods': valuationMethods,
      'manageVariant': manageVariant,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'status': status,
      'page': page,
      'size': size,
    };

  }

}