import 'dart:async';

import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:flutter/material.dart';

class ProductSelectorSheet extends StatefulWidget {
  const ProductSelectorSheet({
    super.key,
    required this.products,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onSearchChanged,
  });

  final List<Product> products;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final ValueChanged<String>? onSearchChanged;

  @override
  State<ProductSelectorSheet> createState() => _ProductSelectorSheetState();
}

class _ProductSelectorSheetState extends State<ProductSelectorSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.toLowerCase();
    final filteredProducts = widget.products.where((product) {
      return product.name.toLowerCase().contains(normalizedQuery) ||
          product.code.toLowerCase().contains(normalizedQuery);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Buscar producto',
                hintText: 'Nombre o código',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
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
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: (filteredProducts.isEmpty
                              ? 1
                              : filteredProducts.length) +
                          (widget.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final resultCount = filteredProducts.isEmpty
                            ? 1
                            : filteredProducts.length;
                        if (widget.hasMore && index == resultCount) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: OutlinedButton.icon(
                                onPressed: widget.isLoadingMore
                                    ? null
                                    : widget.onLoadMore,
                                icon: widget.isLoadingMore
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.expand_more_rounded),
                                label: Text(
                                  widget.isLoadingMore
                                      ? 'Cargando...'
                                      : 'Ver más productos',
                                ),
                              ),
                            ),
                          );
                        }
                        if (filteredProducts.isEmpty && index == 0) {
                          return const SizedBox(
                            height: 220,
                            child: _EmptySearchResult(),
                          );
                        }
                        final product = filteredProducts[index];
                        final hasStock = product.availableStock > 0;
                        final price = product.promoPrice ?? product.basePrice;

                        return ListTile(
                          enabled: hasStock,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          title: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${product.code} · S/ ${price.toStringAsFixed(2)}\n'
                            'Disponible: ${product.availableStock}',
                          ),
                          isThreeLine: true,
                          trailing: hasStock
                              ? const Icon(Icons.add_circle_outline_rounded)
                              : const Text('Sin stock'),
                          onTap: hasStock
                              ? () => Navigator.of(context).pop(product)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    setState(() => _query = query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      widget.onSearchChanged?.call(query);
    });
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 42),
          SizedBox(height: 10),
          Text('No se encontraron productos.'),
        ],
      ),
    );
  }
}
