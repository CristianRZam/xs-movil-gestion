import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:app_movil_sistema/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:app_movil_sistema/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:app_movil_sistema/features/home/presentation/widgets/owner_dashboard.dart';
import 'package:app_movil_sistema/features/home/presentation/widgets/dashboard_sale_analityc.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-date-range-picker.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-filter-button.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-select.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DashboardSummary?> _dashboardFuture;
  late Future<List<DashboardSeller>> _sellersFuture;
  late DashboardFilter _filter;

  bool get _canViewDashboard => getIt<AccessControl>().hasAnyPermission(const [
    'VIEW_DASHBOARD',
    'VIEW_OWN_DASHBOARD',
  ]);
  bool get _canViewGlobal => getIt<AccessControl>().hasAnyPermission(const [
    'VIEW_DASHBOARD',
  ]);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _filter = DashboardFilter(
      fromDate: now.subtract(const Duration(days: 6)),
      toDate: now,
      scope: _canViewGlobal ? 'GLOBAL' : 'MY_SALES',
    );
    _dashboardFuture = _loadDashboard();
    _sellersFuture = _canViewGlobal ? _loadSellers() : Future.value(const []);
  }

  Future<List<DashboardSeller>> _loadSellers() async {
    final result = await getIt<DashboardRepository>().getSellers();
    return result.fold((_) => const [], (sellers) {
      final ids = <int>{};
      return sellers.where((seller) => ids.add(seller.id)).toList();
    });
  }

  Future<DashboardSummary?> _loadDashboard() async {
    if (!_canViewDashboard) {
      return null;
    }
    final result = await getIt<GetDashboardSummaryUseCase>()(_filter);
    return result.fold((_) => null, (summary) => summary);
  }

  Future<void> _showFilters() async {
    final updatedFilter = await showModalBottomSheet<DashboardFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => _DashboardFilterSheet(
        filter: _filter,
        sellersFuture: _sellersFuture,
        canViewGlobal: _canViewGlobal,
      ),
    );

    if (updatedFilter == null || !mounted) return;
    setState(() => _filter = updatedFilter);
    await _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final future = _loadDashboard();
    setState(() {
      _dashboardFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final access = getIt<AccessControl>();
    return ListenableBuilder(
      listenable: access,
      builder: (context, _) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: const XsAppBar(title: 'Inicio', backIcon: false),
        endDrawer: const XsDrawer(),
        body: !_canViewDashboard
            ? const _DashboardAccessDenied()
            : FutureBuilder<DashboardSummary?>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final summary = snapshot.data;
            if (summary == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 48),
                      const SizedBox(height: 12),
                      const Text('No se pudo cargar tu resumen'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Reserva espacio para la navegación inferior del dispositivo
                  // y para cualquier barra flotante de la aplicación.
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panel de operaciones',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Indicadores del periodo seleccionado e histórico',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _refresh,
                          tooltip: 'Actualizar',
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DashboardScopeSelector(
                      selectedScope: _filter.scope,
                      canViewGlobal: _canViewGlobal,
                      onSelected: (scope) {
                        setState(() {
                          _filter = _filter.copyWith(
                            scope: scope,
                            clearSeller: true,
                          );
                        });
                        _refresh();
                      },
                      onFilter: _showFilters,
                    ),
                    const SizedBox(height: 16),
                    OwnerDashboard(summary: summary),
                    const SizedBox(height: 12),
                    DashboardSaleAnalytic(summary: summary),
                  ],
                ),
              ),
              ),
            );
          },
        ),
      ),
    ),
    );
  }

}

class _DashboardScopeSelector extends StatelessWidget {
  const _DashboardScopeSelector({
    required this.selectedScope,
    required this.canViewGlobal,
    required this.onSelected,
    required this.onFilter,
  });

  final String selectedScope;
  final bool canViewGlobal;
  final ValueChanged<String> onSelected;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const darkSelectorSurface = Color(0xFF201416);
    const darkSelectorBorder = Color(0xFF4A282C);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? darkSelectorSurface
                  : AppColors.primary.withValues(alpha: .065),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? darkSelectorBorder
                    : AppColors.primary.withValues(alpha: .16),
              ),
            ),
            child: Row(
              children: [
                if (canViewGlobal)
                  Expanded(
                    child: _ScopeOption(
                      selected: selectedScope == 'GLOBAL',
                      icon: Icons.grid_view_rounded,
                      label: 'General',
                      onTap: () => onSelected('GLOBAL'),
                    ),
                  ),
                Expanded(
                  child: _ScopeOption(
                    selected: selectedScope == 'MY_SALES',
                    icon: Icons.person_outline_rounded,
                    label: 'Mis ventas',
                    onTap: () => onSelected('MY_SALES'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        XsFilterButton(
          tooltip: 'Mostrar filtros',
          onPressed: onFilter,
        ),
      ],
    );
  }
}

class _ScopeOption extends StatelessWidget {
  const _ScopeOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const darkSelected = Color(0xFF3A1E22);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? darkSelected : AppColors.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? .28 : .22,
                      ),
                      blurRadius: isDark ? 10 : 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardFilterSheet extends StatefulWidget {
  const _DashboardFilterSheet({
    required this.filter,
    required this.sellersFuture,
    required this.canViewGlobal,
  });

  final DashboardFilter filter;
  final Future<List<DashboardSeller>> sellersFuture;
  final bool canViewGlobal;

  @override
  State<_DashboardFilterSheet> createState() => _DashboardFilterSheetState();
}

class _DashboardFilterSheetState extends State<_DashboardFilterSheet> {
  late DateTimeRange _dateRange;
  late int? _sellerId;

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(
      start: widget.filter.fromDate,
      end: widget.filter.toDate,
    );
    _sellerId = widget.filter.sellerId;
  }

  void _clear() {
    final now = DateTime.now();
    setState(() {
      _dateRange = DateTimeRange(start: now, end: now);
      _sellerId = null;
    });
  }

  void _apply() {
    final isGlobal = widget.filter.scope == 'GLOBAL';
    Navigator.of(context).pop(
      DashboardFilter(
        fromDate: _dateRange.start,
        toDate: _dateRange.end,
        scope: widget.filter.scope,
        sellerId: isGlobal && widget.canViewGlobal ? _sellerId : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final lastDate = DateTime(now.year, now.month, now.day);
    final firstDate = DateTime(now.year - 1, now.month, now.day);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filtros del dashboard', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Define el periodo que quieres consultar.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              XsDateRangePicker(
                value: _dateRange,
                firstDate: firstDate,
                lastDate: lastDate,
                onChanged: (range) => setState(() => _dateRange = range),
              ),
              if (widget.canViewGlobal && widget.filter.scope == 'GLOBAL')
                FutureBuilder<List<DashboardSeller>>(
                  future: widget.sellersFuture,
                  builder: (context, snapshot) {
                    final sellers = snapshot.data ?? const <DashboardSeller>[];
                    final options = _sellerOptions(sellers);
                    final selected = options.firstWhere(
                      (option) => option.sellerId == _sellerId,
                      orElse: () => options.first,
                    );
                    return XsSelect<_DashboardSellerOption>(
                      labelText: 'Vendedor',
                      prefixIcon: const Icon(Icons.person_search_outlined),
                      items: options,
                      value: selected,
                      enabled: snapshot.connectionState != ConnectionState.waiting,
                      labelBuilder: (option) => option.label,
                      onChanged: (option) {
                        setState(() => _sellerId = option?.sellerId);
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_DashboardSellerOption> _sellerOptions(List<DashboardSeller> sellers) {
    final ids = <int>{};
    return [
      const _DashboardSellerOption(label: 'Todos los vendedores'),
      ...sellers
          .where((seller) => ids.add(seller.id))
          .map(
            (seller) => _DashboardSellerOption(
              sellerId: seller.id,
              label: seller.name,
            ),
          ),
    ];
  }

}

class _DashboardSellerOption {
  const _DashboardSellerOption({this.sellerId, required this.label});

  final int? sellerId;
  final String label;
}

class _DashboardAccessDenied extends StatelessWidget {
  const _DashboardAccessDenied();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 48),
            SizedBox(height: 12),
            Text('No tienes permiso para visualizar el dashboard.'),
          ],
        ),
      ),
    );
  }
}
