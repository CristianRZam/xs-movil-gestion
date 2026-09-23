import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/core/validators/input_validators.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_create_request.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_detail.dart';
import 'package:app_movil_sistema/features/inventory_movement/presentation/widgets/inventory_count_movement_sheet.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_request.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_response.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_request.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/presentation/bloc/product_bloc.dart';
import 'package:app_movil_sistema/features/product/presentation/bloc/product_event.dart';
import 'package:app_movil_sistema/features/product/presentation/bloc/product_state.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-dialog.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-number-field.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-select.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-textfield.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs_multi_filter.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_card.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_search.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_summary_card.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokenStorage = getIt<TokenStorage>();

    final TextEditingController searchController = TextEditingController();
    String searchValue = "";

    final GlobalKey<XsMultiFilterState> categoryKey =
        GlobalKey<XsMultiFilterState>();

    List<int> selectedCategories = [];

    return FutureBuilder<String?>(
      future: tokenStorage.getToken(),
      builder: (context, snapshot) {
        final hasToken = snapshot.hasData && snapshot.data != null;

        return PopScope(
          canPop: !hasToken,
          onPopInvokedWithResult: (didPop, result) {
            if (hasToken && !didPop) {
              SystemNavigator.pop();
            }
          },

          child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state.formResponse != null) {
                openProductDialog(context, state.formResponse!);

                context.read<ProductBloc>().add(const ClearProductForm());
              }

              if (state.product != null) {
                Navigator.of(context).pop();

                context.read<ProductBloc>().add(const ClearSavedProduct());

                context.read<ProductBloc>().add(
                  FilterProductView(
                    ProductViewRequest(
                      page: 0,
                      size: EnvConfig.productPageSize,
                    ),
                  ),
                );
              }

              if (state.deleted == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Producto eliminado correctamente"),
                  ),
                );

                context.read<ProductBloc>().add(const ClearDeletedProduct());

                context.read<ProductBloc>().add(
                  FilterProductView(
                    ProductViewRequest(
                      page: 0,
                      size: EnvConfig.productPageSize,
                    ),
                  ),
                );
              }

              if (state.inventoryMovement != null) {
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Movimiento registrado correctamente"),
                  ),
                );

                context.read<ProductBloc>().add(
                  const ClearSavedInventoryMovement(),
                );

                context.read<ProductBloc>().add(
                  FilterProductView(
                    ProductViewRequest(
                      page: 0,
                      size: EnvConfig.productPageSize,
                    ),
                  ),
                );
              }

              if (state.inventoryMovements != null) {
                openInventoryMovementHistoryDialog(
                  context,
                  state.inventoryMovements!,
                );

                context.read<ProductBloc>().add(
                  const ClearInventoryMovements(),
                );
              }
            },

            builder: (context, state) {
              final response = state.response;
              final products = response?.products ?? [];

              return Scaffold(
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                appBar: const XsAppBar(title: "Productos", backIcon: false),

                endDrawer: const XsDrawer(),

                floatingActionButton:
                    !getIt<AccessControl>().allows(AppCapability.manageProducts)
                    ? null
                    : FloatingActionButton.extended(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.add),
                        label: const Text("Nuevo producto"),
                        onPressed: () {
                          context.read<ProductBloc>().add(
                            const LoadProductForm(ProductFormRequest()),
                          );
                        },
                      ),

                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ProductSummaryCard(
                                title: "Productos",
                                value: "${response?.totalProducts ?? 0}",
                                icon: Icons.inventory_2_outlined,
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ProductSummaryCard(
                                title: "Activos",
                                value: "${response?.activeProducts ?? 0}",
                                icon: Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ProductSummaryCard(
                                title: "Stock",
                                value: "${response?.totalStock ?? 0}",
                                icon: Icons.inventory,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        ProductSearch(
                          controller: searchController,

                          onChanged: (value) {
                            searchValue = value;
                          },
                        ),

                        const SizedBox(height: 16),

                        XsMultiFilter(
                          key: categoryKey,
                          items: response?.categories ?? [],
                          labelBuilder: (category) {
                            return category.name;
                          },
                          valueBuilder: (category) {
                            return category.parameterId;
                          },
                          onChanged: (values) {
                            selectedCategories = values;
                          },
                        ),

                        const SizedBox(height: 18),

                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    searchController.clear();
                                    searchValue = "";
                                    categoryKey.currentState?.clear();
                                    context.read<ProductBloc>().add(
                                      const ClearProductFilter(),
                                    );
                                  },

                                  borderRadius: BorderRadius.circular(30),

                                  child: const Center(
                                    child: Icon(
                                      Icons.restart_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.white24,
                              ),

                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: () {
                                    debugPrint("Aplicando filtros");

                                    debugPrint("Producto: $searchValue");

                                    debugPrint(
                                      "Categorías: $selectedCategories",
                                    );

                                    context.read<ProductBloc>().add(
                                      FilterProductView(
                                        ProductViewRequest(
                                          name: searchValue,
                                          categories: selectedCategories,
                                          page: 0,
                                          size: EnvConfig.productPageSize,
                                        ),
                                      ),
                                    );
                                  },

                                  borderRadius: BorderRadius.circular(30),

                                  child: const Center(
                                    child: Text(
                                      "Aplicar filtros",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,

                                onEnttry: () {
                                  debugPrint(
                                    "Agregar inventario -> ${product.id} - ${product.name}",
                                  );

                                  openInventoryMovementDialog(
                                    context,
                                    product: product,
                                    type: "ENTRY",
                                  );
                                },

                                onWaste: () {
                                  openInventoryMovementDialog(
                                    context,
                                    product: product,
                                    type: "WASTE",
                                  );
                                },

                                onAdjustment: () {
                                  openInventoryMovementDialog(
                                    context,
                                    product: product,
                                    type: "ADJUSTMENT",
                                  );
                                },

                                onMovement: () {
                                  showInventoryCountMovementSheet(
                                    context: context,
                                    productId: product.id,
                                    productName: product.name,
                                  );
                                },

                                onEdit: () {
                                  context.read<ProductBloc>().add(
                                    LoadProductForm(
                                      ProductFormRequest(id: product.id),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Eliminar producto"),
                                      content: Text(
                                        "¿Está seguro de eliminar '${product.name}'?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancelar"),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Eliminar"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    context.read<ProductBloc>().add(
                                      DeleteProduct(product.id),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        if (response != null &&
                            products.length < response.totalProducts) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: state.isLoadingMore
                                  ? null
                                  : () => context.read<ProductBloc>().add(
                                      const LoadMoreProducts(),
                                    ),
                              icon: state.isLoadingMore
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more_rounded),
                              label: Text(
                                state.isLoadingMore
                                    ? 'Cargando...'
                                    : 'Ver más (${products.length} de ${response.totalProducts})',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

void openProductDialog(
  BuildContext parentContext,
  ProductFormResponse response,
) {
  final product = response.product;

  final codeController = TextEditingController(text: product?.code ?? "");

  final nameController = TextEditingController(text: product?.name ?? "");

  final priceController = TextEditingController(
    text: product?.basePrice.toStringAsFixed(2) ?? "",
  );

  final descriptionController = TextEditingController(
    text: product?.description ?? "",
  );

  showDialog(
    context: parentContext,

    builder: (_) {
      int? selectedCategoryId = product?.categoryId;
      final formKey = GlobalKey<FormState>();

      return StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: XsDialog(
              title: product == null ? "Nuevo producto" : "Editar producto",

              confirmText: product == null ? "Guardar" : "Actualizar",

              onConfirm: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final isNew = product == null;

                if (isNew) {
                  final request = ProductRequest(
                    code: codeController.text.trim(),
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    categoryId: selectedCategoryId!,
                    unitMeasureId: response.unitMeasures.first.parameterId,
                    valuationMethodId:
                        response.valuationMethods.first.parameterId,
                    basePrice: double.parse(priceController.text),
                    promoPrice: null,
                    baseCost: 0,
                  );

                  parentContext.read<ProductBloc>().add(CreateProduct(request));
                } else {
                  final request = ProductRequest(
                    id: product.id,

                    code: codeController.text.trim(),
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    categoryId: selectedCategoryId!,

                    // Estos NO los edita el usuario
                    unitMeasureId: product.unitMeasureId,
                    valuationMethodId: product.valuationMethodId,
                    baseCost: product.baseCost,
                    promoPrice: product.promoPrice,

                    basePrice: double.parse(priceController.text),
                  );

                  parentContext.read<ProductBloc>().add(UpdateProduct(request));
                }
              },

              child: Column(
                children: [
                  XsTextField(
                    controller: codeController,
                    labelText: "Código",
                    prefixIcon: const Icon(Icons.qr_code),
                    autoValidate: true,
                    validator: (value) => composeValidators([
                      InputValidators.requiredField("Ingrese el código"),
                    ], value),
                  ),

                  const SizedBox(height: 12),

                  XsTextField(
                    controller: nameController,
                    labelText: "Nombre",
                    prefixIcon: const Icon(Icons.inventory),
                    autoValidate: true,
                    validator: (value) => composeValidators([
                      InputValidators.requiredField("Ingrese el nombre"),
                    ], value),
                  ),

                  const SizedBox(height: 12),

                  XsSelect(
                    labelText: "Categoría",
                    items: response.categories,
                    initialValue: product == null
                        ? null
                        : response.categories.firstWhere(
                            (e) => e.parameterId == product.categoryId,
                          ),
                    labelBuilder: (item) => item.name,
                    prefixIcon: const Icon(Icons.category),
                    autoValidate: true,
                    validator: InputValidators.requiredSelect(
                      "Seleccione una categoría",
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value?.parameterId;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  XsNumberField(
                    controller: priceController,
                    labelText: "Precio",
                    decimal: true,
                    prefixIcon: const Icon(Icons.attach_money),
                    validator: (value) => composeValidators([
                      InputValidators.requiredField("Ingrese el precio"),
                    ], value),
                  ),

                  const SizedBox(height: 12),

                  XsTextField(
                    controller: descriptionController,
                    labelText: "Descripción",
                    keyboardType: TextInputType.multiline,
                    prefixIcon: const Icon(Icons.description),
                    autoValidate: true,
                    validator: (value) => composeValidators([
                      InputValidators.requiredField("Ingrese la descripción"),
                    ], value),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void openInventoryMovementDialog(
  BuildContext parentContext, {
  required Product product,
  required String type,
}) {
  final quantityController = TextEditingController();

  final commentController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  showDialog(
    context: parentContext,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: XsDialog(
              title: type == "ENTRY"
                  ? "Agregar inventario"
                  : type == "WASTE"
                  ? "Registrar merma"
                  : "Ajustar inventario",

              confirmText: type == "ENTRY"
                  ? "Guardar"
                  : type == "WASTE"
                  ? "Registrar"
                  : "Ajustar",

              onConfirm: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final request = InventoryMovementCreateRequest(
                  productId: product.id,
                  type: type,
                  quantity: double.parse(quantityController.text),
                  previousStock: 0,
                  currentStock: 0,
                  reason: commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                  referenceType: null,
                  referenceId: null,
                );

                parentContext.read<ProductBloc>().add(
                  CreateInventoryMovement(request),
                );
              },

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Información del producto
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Código: ${product.code}",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                "Stock actual: ${product.totalStock}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Cantidad
                  XsNumberField(
                    controller: quantityController,
                    labelText: "Cantidad",
                    decimal: true,
                    prefixIcon: const Icon(Icons.inventory),
                    validator: (value) => composeValidators([
                      InputValidators.requiredField("Ingrese la cantidad"),
                    ], value),
                  ),

                  const SizedBox(height: 16),

                  // Comentarios
                  XsTextField(
                    controller: commentController,
                    labelText: "Comentarios",
                    keyboardType: TextInputType.multiline,
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void openInventoryMovementHistoryDialog(
  BuildContext context,
  List<InventoryMovementDetail> movements,
) {
  final theme = Theme.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final backgroundColor = theme.scaffoldBackgroundColor;
  final surfaceColor = theme.cardColor;

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: surfaceColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        child: SizedBox(
          width: 420,
          height: 600,

          child: Column(
            children: [
              /// HEADER
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: isDark ? AppColors.dark : AppColors.primary,

                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, color: Colors.white),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Movimientos",

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            movements.first.productName,

                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .75),
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () => Navigator.pop(context),

                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  color: backgroundColor,

                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),

                    itemCount: movements.length,

                    separatorBuilder: (_, __) => const SizedBox(height: 14),

                    itemBuilder: (_, index) {
                      final movement = movements[index];

                      return _MovementCard(
                        type: movement.type,

                        quantity: movement.quantity,

                        previous: movement.previousStock,

                        current: movement.currentStock,

                        reason: movement.reason ?? "",

                        date: DateFormat(
                          "dd/MM/yyyy HH:mm",
                        ).format(movement.createdAt),

                        user: movement.createdBy,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String formatQuantity(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }

  return value.toString();
}

class _MovementCard extends StatelessWidget {
  final String type;
  final double quantity;
  final double previous;
  final double current;
  final String reason;
  final String date;
  final String user;

  const _MovementCard({
    required this.type,
    required this.quantity,
    required this.previous,
    required this.current,
    required this.reason,
    required this.date,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final theme = Theme.of(context);

    late final Color color;
    late final IconData icon;
    late final String title;
    late final String badge;
    late final String quantityText;

    switch (type) {
      case "ENTRY":
        color = Colors.green;
        icon = Icons.inventory_2_outlined;
        title = "Entrada de inventario";
        badge = "ENTRADA";
        quantityText = "+${formatQuantity(quantity)}";
        break;

      case "SALE":
        color = Colors.blue;
        icon = Icons.shopping_bag_outlined;
        title = "Venta";
        badge = "VENTA";
        quantityText = "-${formatQuantity(quantity)}";
        break;

      case "SALE_RETURN":
        color = Colors.deepPurple;
        icon = Icons.assignment_return_outlined;
        title = "Devolución";
        badge = "DEVOLUCIÓN";
        quantityText = "+${formatQuantity(quantity)}";
        break;

      case "WASTE":
        color = Colors.red;
        icon = Icons.delete_outline;
        title = "Merma";
        badge = "MERMA";
        quantityText = "-${formatQuantity(quantity)}";
        break;

      case "ADJUSTMENT":
        color = Colors.orange;
        icon = Icons.tune;
        title = "Ajuste";
        badge = "AJUSTE";
        quantityText =
            "${formatQuantity(previous)} → ${formatQuantity(current)}";
        break;

      default:
        color = Colors.grey;
        icon = Icons.history;
        title = "Movimiento";
        badge = "DESCONOCIDO";
        quantityText = formatQuantity(quantity);
    }

    return Card(
      elevation: 0,

      color: theme.cardColor,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: BorderSide(color: color.withValues(alpha: .15)),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,

                  backgroundColor: color.withValues(alpha: .10),

                  child: Icon(icon, color: color),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,

                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,

                          fontWeight: FontWeight.w700,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,

                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .10),

                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Text(
                          badge,

                          style: TextStyle(
                            color: color,

                            fontWeight: FontWeight.bold,

                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  quantityText,

                  style: TextStyle(
                    color: color,

                    fontWeight: FontWeight.bold,

                    fontSize: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Motivo
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: .05)
                    : Colors.grey.shade100,

                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.description_outlined,

                    size: 18,

                    color: theme.iconTheme.color,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      reason,

                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Stock
            Row(
              children: [
                Expanded(
                  child: _StockItem(
                    title: "Anterior",

                    value: formatQuantity(previous),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),

                  child: Icon(Icons.arrow_forward_rounded, color: color),
                ),

                Expanded(
                  child: _StockItem(
                    title: "Actual",

                    value: formatQuantity(current),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Divider(color: theme.dividerColor),

            const SizedBox(height: 10),

            /// Footer
            Row(
              children: [
                Icon(
                  Icons.person_outline,

                  size: 18,

                  color: theme.iconTheme.color,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    user,

                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                ),

                Icon(
                  Icons.schedule_outlined,

                  size: 18,

                  color: theme.iconTheme.color,
                ),

                const SizedBox(width: 6),

                Text(
                  date,

                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockItem extends StatelessWidget {
  final String title;
  final String value;

  const _StockItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),

      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : Colors.grey.shade100,

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Text(
            title,

            style: TextStyle(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: .65),

              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,

              fontWeight: FontWeight.bold,

              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
