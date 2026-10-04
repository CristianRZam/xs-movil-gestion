import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/order/domain/usecases/order_usecases.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_bloc.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_event.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_state.dart';
import 'package:app_movil_sistema/features/order/presentation/pages/order_view.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:app_movil_sistema/features/shared/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final bloc = OrderBloc(
        getIt<GetOrdersUseCase>(),
        getIt<CreateOrderUseCase>(),
        getIt<UpdateOrderUseCase>(),
        getIt<UpdateOrderStatusUseCase>(),
        getIt<DeleteOrderUseCase>(),
        getIt<GetProductViewUseCase>(),
        getIt<ExistsOpenCashSessionUseCase>(),
      )
        ..add(const LoadOrders());
      final access = getIt<AccessControl>();
      if (access.allows(AppCapability.createOrders)) {
        bloc.add(const CheckOpenCashSession());
      }
      if (access.allows(AppCapability.createOrders) ||
          access.allows(AppCapability.editOrders)) {
        bloc.add(const LoadOrderProducts());
      }
      return bloc;
    },
    child: BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) => LoadingOverlay(
        isLoading: state.status == OrderStatus.loading,
        child: const OrderView(),
      ),
    ),
  );
}
