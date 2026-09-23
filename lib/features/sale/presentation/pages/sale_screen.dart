import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:app_movil_sistema/features/sale/domain/usecases/sale_usecases.dart';
import 'package:app_movil_sistema/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:app_movil_sistema/features/sale/presentation/pages/sale_view.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleScreen extends StatelessWidget {
  const SaleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    final order = argument is Order ? argument : null;
    return BlocProvider(
      create: (_) => SaleBloc(
        getIt<GetSalesUseCase>(),
        getIt<CreateSaleUseCase>(),
        getIt<GetProductViewUseCase>(),
        getIt<ExistsOpenCashSessionUseCase>(),
      )..add(const LoadSales()),
      child: BlocBuilder<SaleBloc, SaleState>(
        builder: (_, state) => LoadingOverlay(
          isLoading: state.status == SaleStatus.loading,
          child: SaleView(order: order),
        ),
      ),
    );
  }
}
