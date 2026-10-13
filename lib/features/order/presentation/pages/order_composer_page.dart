import 'dart:async';

import 'package:app_movil_sistema/features/order/domain/entities/order.dart';
import 'package:app_movil_sistema/features/order/domain/entities/order_item.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_bloc.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_event.dart';
import 'package:app_movil_sistema/features/order/presentation/bloc/order_state.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderComposerPage extends StatefulWidget {
  const OrderComposerPage({
    super.key,
    this.order,
    this.appendItemsOnly = false,
    required this.initialProducts,
  });

  final Order? order;
  final bool appendItemsOnly;
  final List<Product> initialProducts;

  @override
  State<OrderComposerPage> createState() => _OrderComposerPageState();
}

class _OrderComposerPageState extends State<OrderComposerPage> {
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;
  late String _orderType;
  late List<OrderItem> _items;
  late final Map<int, Product> _productsById;
  bool _saving = false;

  bool get _isAppending => widget.appendItemsOnly;
  bool get _isEditing => widget.order != null && !_isAppending;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(
      text: widget.order?.tableNumber ?? '',
    );
    _notesController = TextEditingController(text: widget.order?.notes ?? '');
    _orderType = widget.order?.orderType ?? 'DINE_IN';
    _items = _isAppending ? [] : [...?widget.order?.items];
    _productsById = {
      for (final product in widget.initialProducts) product.id: product,
    };
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          for (final product in state.products) {
            _productsById[product.id] = product;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(_appBarTitle),
              actions: [
                if (!_isAppending)
                  IconButton(
                    tooltip: 'Editar datos de la orden',
                    onPressed: _showOrderDetails,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                IconButton(
                  tooltip: 'Ver carrito',
                  onPressed: _showCart,
                  icon: Badge(
                    isLabelVisible: _items.isNotEmpty,
                    label: Text('${_items.length}'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _OrderTypeSelector(
                    orderType: _orderType,
                    isForNewItems: _isAppending,
                    onChanged: _changeOrderType,
                  ),
                  Expanded(
                    child: ProductSelectorSheet(
                      products: state.products,
                      categories: state.productCategories,
                      selectedCategoryIds: state.selectedProductCategoryIds,
                      availableOnly: state.availableProductsOnly,
                      searchQuery: state.productSearchQuery,
                      hasMore: state.hasMoreProducts,
                      isLoadingMore: state.isLoadingMoreProducts,
                      onLoadMore: () => context.read<OrderBloc>().add(
                        const LoadMoreOrderProducts(),
                      ),
                      onSearchChanged: (query) => context
                          .read<OrderBloc>()
                          .add(SearchOrderProducts(query)),
                      onFiltersChanged: (categoryIds, availableOnly) => context
                          .read<OrderBloc>()
                          .add(
                            FilterOrderProducts(
                              categoryIds: categoryIds,
                              availableOnly: availableOnly,
                            ),
                          ),
                      onProductSelected: _addProduct,
                    ),
                  ),
                  _CartBar(
                    itemCount: _items.length,
                    total: _total,
                    onOpenCart: _showCart,
                    onSave: state.status == OrderStatus.loading || _items.isEmpty
                        ? null
                        : _save,
                  ),
                ],
              ),
            ),
          );
        },
      );

  double get _total => _items
      .where((item) => item.status != 'CANCELLED')
      .fold(0.0, (sum, item) => sum + item.subtotal);

  String get _appBarTitle {
    if (_isAppending) {
      return 'Agregar a ${widget.order?.orderNumber ?? 'orden'}';
    }
    final reference = _referenceController.text.trim();
    if (reference.isEmpty) return _isEditing ? 'Editar orden' : 'Nueva orden';
    return _orderType == 'DINE_IN' ? 'Mesa $reference' : reference;
  }

  Future<void> _showOrderDetails() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Datos de la orden',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'DINE_IN',
                        icon: Icon(Icons.table_restaurant_outlined),
                        label: Text('En local'),
                      ),
                      ButtonSegment(
                        value: 'TAKEAWAY',
                        icon: Icon(Icons.shopping_bag_outlined),
                        label: Text('Para llevar'),
                      ),
                      ButtonSegment(
                        value: 'DELIVERY',
                        icon: Icon(Icons.delivery_dining_outlined),
                        label: Text('Entrega'),
                      ),
                    ],
                    selected: {_orderType},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      _changeOrderType(selection.first);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _referenceController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: _referenceLabel,
                      prefixIcon: Icon(_referenceIcon),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    maxLength: 500,
                    minLines: 1,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notas de la orden',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Listo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  String get _referenceLabel => switch (_orderType) {
        'DINE_IN' => 'Mesa',
        'TAKEAWAY' => 'Nombre o referencia',
        _ => 'Referencia de entrega',
      };

  IconData get _referenceIcon => switch (_orderType) {
        'DINE_IN' => Icons.table_restaurant_outlined,
        'TAKEAWAY' => Icons.shopping_bag_outlined,
        _ => Icons.location_on_outlined,
      };

  void _addProduct(Product product) {
    final index = _items.indexWhere((item) => item.productId == product.id);
    final maximum = _maximumQuantity(product.id);
    if (maximum <= 0 ||
        (index >= 0 && _items[index].quantity + 1 > maximum)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solo hay $maximum unidad(es) disponible(s).')),
      );
      return;
    }

    setState(() {
      _productsById[product.id] = product;
      if (index >= 0) {
        final item = _items[index];
        _items[index] = _copyItem(item, quantity: item.quantity + 1);
      } else {
        _items.add(
          OrderItem(
            productId: product.id,
            productName: product.name,
            quantity: 1,
            unitPrice: product.promoPrice ?? product.basePrice,
            fulfillmentType: _fulfillmentType,
          ),
        );
      }
    });
  }

  String get _fulfillmentType => switch (_orderType) {
        'TAKEAWAY' => 'TAKEAWAY',
        'DELIVERY' => 'DELIVERY',
        _ => 'DINE_IN',
      };

  void _changeOrderType(String value) {
    setState(() {
      _orderType = value;
      if (!_isEditing) {
        _items = _items
            .map(
              (item) => _copyItem(item, fulfillmentType: _fulfillmentType),
            )
            .toList();
      }
    });
  }

  int _maximumQuantity(int productId) {
    final product = _productsById[productId];
    if (product == null) return -1;
    if (_isAppending) return product.availableStock;
    final originalReserved = widget.order?.items
            .where((item) => item.productId == productId)
            .fold<double>(0, (sum, item) => sum + item.quantity) ??
        0;
    return product.availableStock + originalReserved.toInt();
  }

  void _showCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .78,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Carrito (${_items.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        'S/ ${_total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(child: Text('Aún no agregó productos.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final item = _items[index];
                            final product = _productsById[item.productId];
                            return _CartItemCard(
                              item: item,
                              productName:
                                  product?.name ?? item.productName ?? 'Producto #${item.productId}',
                              maximumQuantity: _maximumQuantity(item.productId),
                              onDecrease: () => _changeQuantity(index, -1, setSheetState),
                              onIncrease: () => _changeQuantity(index, 1, setSheetState),
                              onEdit: () => _editItem(index, setSheetState),
                              onRemove: () => _removeItem(index, setSheetState),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _items.isEmpty
                          ? null
                          : () {
                              Navigator.of(sheetContext).pop();
                              _save();
                            },
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        _isAppending
                            ? 'Agregar productos'
                            : _isEditing
                            ? 'Guardar cambios'
                            : 'Crear orden',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeQuantity(
    int index,
    int delta,
    void Function(void Function()) setSheetState,
  ) {
    final item = _items[index];
    final next = item.quantity + delta;
    if (next <= 0) {
      _removeItem(index, setSheetState);
      return;
    }
    if (next > _maximumQuantity(item.productId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo hay ${_maximumQuantity(item.productId)} unidad(es) disponible(s).',
          ),
        ),
      );
      return;
    }
    setState(() => _items[index] = _copyItem(item, quantity: next));
    setSheetState(() {});
  }

  void _removeItem(
    int index,
    void Function(void Function()) setSheetState,
  ) {
    setState(() => _items.removeAt(index));
    setSheetState(() {});
  }

  Future<void> _editItem(
    int index,
    void Function(void Function()) setSheetState,
  ) async {
    final item = _items[index];
    final quantity = TextEditingController(text: item.quantity.toInt().toString());
    final price = TextEditingController(text: item.unitPrice.toStringAsFixed(2));
    final notes = TextEditingController(text: item.notes ?? '');
    final result = await showDialog<OrderItem>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Cantidad',
                helperText: 'Máximo: ${_maximumQuantity(item.productId)}',
              ),
            ),
            TextField(
              controller: price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(labelText: 'Precio unitario'),
            ),
            TextField(
              controller: notes,
              maxLength: 255,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notas del producto'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantity.text);
              final newPrice = double.tryParse(price.text);
              if (newQuantity == null ||
                  newQuantity <= 0 ||
                  newQuantity > _maximumQuantity(item.productId) ||
                  newPrice == null ||
                  newPrice <= 0) {
                return;
              }
              Navigator.of(dialogContext).pop(
                _copyItem(
                  item,
                  quantity: newQuantity.toDouble(),
                  unitPrice: newPrice,
                  notes: _nullIfBlank(notes.text),
                ),
              );
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    quantity.dispose();
    price.dispose();
    notes.dispose();
    if (result == null || !mounted) return;
    setState(() => _items[index] = result);
    setSheetState(() {});
  }

  Future<void> _save() async {
    if (!_isAppending &&
        _orderType == 'DINE_IN' &&
        _referenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique la mesa de la orden.')),
      );
      _showOrderDetails();
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un producto.')),
      );
      return;
    }
    for (final item in _items) {
      final maximum = _maximumQuantity(item.productId);
      if (maximum < 0 || item.quantity > maximum) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La cantidad de ${_productsById[item.productId]?.name ?? 'un producto'} supera el stock disponible.',
            ),
          ),
        );
        return;
      }
    }
    final completer = Completer<Order>();
    setState(() => _saving = true);
    if (_isAppending) {
      context.read<OrderBloc>().add(
            AddOrderItems(
              widget.order!.id!,
              _items,
              completer: completer,
            ),
          );
    } else {
      context.read<OrderBloc>().add(
            SaveOrder(
              Order(
                id: widget.order?.id,
                orderNumber: widget.order?.orderNumber ?? '',
                cashRegisterId: widget.order?.cashRegisterId,
                orderType: _orderType,
                tableNumber: _nullIfBlank(_referenceController.text),
                notes: _nullIfBlank(_notesController.text),
                items: _items,
                status: widget.order?.status,
                incidentDiscount: widget.order?.incidentDiscount ?? 0,
                createdAt: widget.order?.createdAt,
                modifiedAt: widget.order?.modifiedAt,
              ),
              completer: completer,
            ),
          );
    }

    try {
      await completer.future;
      if (mounted) Navigator.of(context).pop(true);
    } on StateError catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message.toString())),
      );
    }
  }

  OrderItem _copyItem(
    OrderItem item, {
    double? quantity,
    double? unitPrice,
    String? notes,
    String? fulfillmentType,
  }) =>
      OrderItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        quantity: quantity ?? item.quantity,
        unitPrice: unitPrice ?? item.unitPrice,
        notes: notes ?? item.notes,
        fulfillmentType: fulfillmentType ?? item.fulfillmentType,
        status: item.status,
        createdAt: item.createdAt,
        modifiedAt: item.modifiedAt,
      );
}

class _OrderTypeSelector extends StatelessWidget {
  const _OrderTypeSelector({
    required this.orderType,
    required this.onChanged,
    this.isForNewItems = false,
  });

  final String orderType;
  final ValueChanged<String> onChanged;
  final bool isForNewItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          if (isForNewItems)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 7),
              color: colorScheme.primary,
              child: const Row(
                children: [
                  Icon(Icons.add_shopping_cart_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Los nuevos productos serán',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 7),
            child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'DINE_IN',
                icon: Icon(Icons.table_restaurant_outlined, size: 18),
                label: Text('En local'),
              ),
              ButtonSegment(
                value: 'TAKEAWAY',
                icon: Icon(Icons.shopping_bag_outlined, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Para llevar', softWrap: false),
                ),
              ),
              ButtonSegment(
                value: 'DELIVERY',
                icon: Icon(Icons.delivery_dining_outlined, size: 18),
                label: Text('Entrega'),
              ),
            ],
            selected: {orderType},
            showSelectedIcon: false,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
              visualDensity: VisualDensity.standard,
            ),
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.itemCount,
    required this.total,
    required this.onOpenCart,
    required this.onSave,
  });

  final int itemCount;
  final double total;
  final VoidCallback onOpenCart;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 8,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenCart,
                    icon: Badge(
                      isLabelVisible: itemCount > 0,
                      label: Text('$itemCount'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    label: Text('S/ ${total.toStringAsFixed(2)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.productName,
    required this.maximumQuantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEdit,
    required this.onRemove,
  });

  final OrderItem item;
  final String productName;
  final int maximumQuantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Quitar',
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              if (item.notes?.trim().isNotEmpty == true)
                Text(item.notes!, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Reducir cantidad',
                    onPressed: onDecrease,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    item.quantity.toInt().toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    tooltip: 'Aumentar cantidad',
                    onPressed: item.quantity >= maximumQuantity
                        ? null
                        : onIncrease,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const Spacer(),
                  Text('S/ ${item.subtotal.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ),
      );
}

String? _nullIfBlank(String value) =>
    value.trim().isEmpty ? null : value.trim();

