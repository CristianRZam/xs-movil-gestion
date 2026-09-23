import 'package:app_movil_sistema/features/inventory_movement/domain/usecases/create_inventory_movement_usecase.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/usecases/get_inventory_movements_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/create_product_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_form_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/update_product_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/update_product_status_usecase.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_state.dart';
import '../../../../core/service_locator.dart';

import '../../domain/usecases/get_product_view_usecase.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';

import 'product_view.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductBloc(
            getIt<GetProductViewUseCase>(),
            getIt<GetProductFormUseCase>(),
            getIt<CreateProductUseCase>(),
            getIt<UpdateProductUseCase>(),
            getIt<UpdateProductStatusUseCase>(),
            getIt<DeleteProductUseCase>(),
            getIt<GetInventoryMovementsUseCase>(),
            getIt<CreateInventoryMovementUseCase>(),
          )..add(
            LoadProductView(
              ProductViewRequest(page: 0, size: EnvConfig.productPageSize),
            ),
          ),
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.status == ProductStatus.loading,
            child: const ProductView(),
          );
        },
      ),
    );
  }
}
