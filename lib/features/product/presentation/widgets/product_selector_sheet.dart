import 'dart:async';

import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/parameter/domain/entities/parameter.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:flutter/material.dart';

/// Catálogo reutilizable para seleccionar productos al crear órdenes o ventas.
/// La búsqueda, filtros y paginación se resuelven en el BLoC.
class ProductSelectorSheet extends StatefulWidget {
  const ProductSelectorSheet({
    super.key,
    required this.products,
    this.categories = const [],
    this.selectedCategoryIds = const [],
    this.availableOnly = false,
    this.searchQuery = '',
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onSearchChanged,
    this.onFiltersChanged,
    this.onProductSelected,
  });

  final List<Product> products;
  final List<Parameter> categories;
  final List<int> selectedCategoryIds;
  final bool availableOnly;
  final String searchQuery;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final ValueChanged<String>? onSearchChanged;
  final void Function(List<int> categoryIds, bool availableOnly)? onFiltersChanged;
  final ValueChanged<Product>? onProductSelected;

  @override
  State<ProductSelectorSheet> createState() => _ProductSelectorSheetState();
}

class _ProductSelectorSheetState extends State<ProductSelectorSheet> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant ProductSelectorSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        widget.selectedCategoryIds.isNotEmpty || widget.availableOnly;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (hasFilters)
                  TextButton.icon(
                    onPressed: () => widget.onFiltersChanged?.call(
                      const [],
                      false,
                    ),
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                    label: const Text('Limpiar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Buscar producto',
                hintText: 'Nombre o código',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Disponibles'),
                      avatar: const Icon(Icons.inventory_2_outlined, size: 17),
                      selected: widget.availableOnly,
                      onSelected: (selected) => widget.onFiltersChanged?.call(
                        widget.selectedCategoryIds,
                        selected,
                      ),
                    ),
                  ),
                  for (final category in widget.categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: widget.selectedCategoryIds.contains(
                          category.parameterId,
                        ),
                        onSelected: (selected) {
                          final selectedIds = [
                            ...widget.selectedCategoryIds,
                          ];
                          if (selected) {
                            selectedIds.add(category.parameterId);
                          } else {
                            selectedIds.remove(category.parameterId);
                          }
                          widget.onFiltersChanged?.call(
                            selectedIds,
                            widget.availableOnly,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildCatalog(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context) {
    if (widget.products.isEmpty && !widget.isLoadingMore) {
      return const _EmptySearchResult();
    }

    final productCount = widget.products.length;
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 184,
            mainAxisExtent: 238,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _ProductCatalogCard(
              product: widget.products[index],
              onSelected: widget.onProductSelected,
            ),
            childCount: productCount,
          ),
        ),
        if (widget.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: _LoadMoreCard(
                  isLoading: widget.isLoadingMore,
                  onPressed: widget.isLoadingMore ? null : widget.onLoadMore,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    setState(() {});
    final query = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      widget.onSearchChanged?.call(query);
    });
  }
}

class _ProductCatalogCard extends StatelessWidget {
  const _ProductCatalogCard({required this.product, this.onSelected});

  final Product product;
  final ValueChanged<Product>? onSelected;

  @override
  Widget build(BuildContext context) {
    final canAdd = product.availableStock > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final price = product.promoPrice ?? product.basePrice;
    final hasPromotion = product.promoPrice != null &&
        product.promoPrice! < product.basePrice;
    const accent = AppColors.primary;

    void select() {
      if (!canAdd) return;
      if (onSelected != null) {
        onSelected!(product);
      } else {
        Navigator.of(context).pop(product);
      }
    }

    void showDescription() {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(sheetContext).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.code,
                              style: Theme.of(sheetContext).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Descripción',
                    style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.description!.trim(),
                      style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Entendido'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: canAdd ? 1 : .62,
      child: Material(
        color: Colors.transparent,
        elevation: canAdd ? 2 : 0,
        shadowColor: accent.withValues(alpha: canAdd ? .09 : 0),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canAdd ? select : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(
                color: canAdd
                    ? accent.withValues(alpha: .22)
                    : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _ProductImage(imageUrl: product.mainImageUrl),
                          ),
                        ),
                      ),
                      if (hasPromotion)
                        Positioned(
                          top: 14,
                          left: 14,
                          child: _Badge(
                            label: 'Oferta',
                            color: accent,
                          ),
                        ),
                      if (product.description?.trim().isNotEmpty == true)
                        Positioned(
                          top: 12,
                          left: hasPromotion ? 76 : 12,
                          child: IconButton.filledTonal(
                            tooltip: 'Ver descripción',
                            onPressed: showDescription,
                            icon: const Icon(Icons.info_outline_rounded),
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton.filled(
                          tooltip: canAdd
                              ? 'Agregar ${product.name}'
                              : 'Sin stock disponible',
                          onPressed: canAdd ? select : null,
                          icon: const Icon(Icons.add_rounded),
                          iconSize: 19,
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 9,
                        left: 14,
                        child: _StockBadge(
                          quantity: product.availableStock,
                          available: canAdd,
                        ),
                      ),
                      Positioned(
                        bottom: 9,
                        right: 14,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: .28),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Text(
                              'S/ ${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (imageUrl?.trim().isEmpty ?? true) return _fallback(colorScheme);

    return Image.network(
      EnvConfig.resolveBackendFileUrl(imageUrl!.trim()),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _fallback(colorScheme),
    );
  }

  Widget _fallback(ColorScheme colorScheme) => ColoredBox(
    color: colorScheme.surfaceContainerHighest,
    child: Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.quantity, required this.available});

  final int quantity;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = available
        ? colorScheme.surface.withValues(alpha: .94)
        : colorScheme.errorContainer.withValues(alpha: .96);
    final foreground = available ? colorScheme.onSurface : colorScheme.onErrorContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: .1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          available ? '$quantity disp.' : 'Sin stock',
          style: TextStyle(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: TextStyle(
          color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _LoadMoreCard extends StatelessWidget {
  const _LoadMoreCard({required this.isLoading, this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
    icon: isLoading
        ? const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.expand_more_rounded, size: 18),
    label: Text(isLoading ? 'Cargando...' : 'Ver más productos'),
  );
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inventory_2_outlined, size: 48),
        SizedBox(height: 10),
        Text('No se encontraron productos.'),
      ],
    ),
  );
}
