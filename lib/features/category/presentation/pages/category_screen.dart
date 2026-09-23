import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_create_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';
import 'package:app_movil_sistema/features/category/domain/usecases/category_usecases.dart';
import 'package:app_movil_sistema/features/category/presentation/bloc/category_cubit.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CategoryCubit(
      getIt<GetCategoriesUseCase>(),
      getIt<CreateCategoryUseCase>(),
    )..load(),
    child: const _CategoryView(),
  );
}

class _CategoryView extends StatefulWidget {
  const _CategoryView();

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() => context.read<CategoryCubit>().load(
    _searchController.text.trim().isEmpty ? null : _searchController.text,
  );

  void _reset() {
    _searchController.clear();
    context.read<CategoryCubit>().load();
  }

  Future<void> _openCreateSheet() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: context.read<CategoryCubit>(),
      child: const _CreateCategorySheet(),
    ),
  );

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<CategoryCubit, CategoryState>(
    listener: (context, state) {
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        context.read<CategoryCubit>().clearFeedback();
      }
      if (state.created) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría creada correctamente')),
        );
        final search = state.search;
        context.read<CategoryCubit>()
          ..clearFeedback()
          ..load(search);
      }
    },
    builder: (context, state) => Scaffold(
      appBar: const XsAppBar(title: 'Categorías', backIcon: false),
      endDrawer: const XsDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSaving ? null : _openCreateSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva categoría'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<CategoryCubit>().load(state.search),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
            children: [
              Text(
                'Categorías de productos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Organiza los productos y define el orden en que se mostrarán.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        hintText: 'Buscar categoría...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Buscar',
                    onPressed: state.status == CategoryStatus.loading
                        ? null
                        : _search,
                    icon: const Icon(Icons.search_rounded),
                  ),
                  IconButton(
                    tooltip: 'Restablecer',
                    onPressed: state.status == CategoryStatus.loading
                        ? null
                        : _reset,
                    icon: const Icon(Icons.restart_alt_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state.status == CategoryStatus.loading &&
                  state.categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.categories.isEmpty)
                const _EmptyCategories()
              else ...[
                Text(
                  '${state.categories.length} categoría${state.categories.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 10),
                ...state.categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CategoryCard(category: category),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final ProductCategory category;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          category.orderNumber.toString(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: category.shortName?.isNotEmpty == true
          ? Text(category.shortName!)
          : const Text('Sin nombre corto'),
      trailing: Chip(
        label: Text(category.active ? 'Activa' : 'Inactiva'),
        visualDensity: VisualDensity.compact,
      ),
    ),
  );
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 48),
    child: Column(
      children: [
        Icon(
          Icons.category_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 12),
        const Text('No se encontraron categorías.'),
      ],
    ),
  );
}

class _CreateCategorySheet extends StatefulWidget {
  const _CreateCategorySheet();

  @override
  State<_CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends State<_CreateCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _orderController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CategoryCubit>().create(
      CategoryCreateRequest(
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim().isEmpty
            ? null
            : _shortNameController.text.trim(),
        orderNumber: int.parse(_orderController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) => Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva categoría',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                maxLength: 255,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingrese el nombre de la categoría'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _shortNameController,
                maxLength: 255,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre corto',
                  prefixIcon: Icon(Icons.short_text_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _orderController,
                maxLength: 9,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Orden',
                  hintText: 'Ej. 1',
                  prefixIcon: Icon(Icons.format_list_numbered_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final order = int.tryParse(value?.trim() ?? '');
                  if (order == null || order < 0) {
                    return 'Ingrese un número entero válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isSaving ? null : _submit,
                  icon: state.isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    state.isSaving ? 'Guardando...' : 'Crear categoría',
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
