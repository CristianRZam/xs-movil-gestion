
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';

class XsDrawer extends StatelessWidget {
  const XsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final access = getIt<AccessControl>();

    final canProducts =
    access.allows(AppCapability.viewProducts);

    final canOrders =
    access.allows(AppCapability.viewOrders);

    final canSales =
    access.allows(AppCapability.viewSales);

    final canCashSession =
    access.allows(AppCapability.viewCashSession);

    final canReports =
    access.allows(AppCapability.reports);

    final canInventoryCount =
    access.allows(AppCapability.viewInventoryCount);

    final canCategories =
    access.allows(AppCapability.manageCategories);

    final canUsers =
    access.allows(AppCapability.manageUsers);

    final canRoles =
    access.allows(AppCapability.manageRoles);

    final backgroundColor =
    isDarkMode ? AppColors.darkBody : AppColors.lightBackground;

    final surfaceColor =
    isDarkMode ? AppColors.dark : Colors.white;

    return Material(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [

// =====================================================
// HEADER
// =====================================================

            _DrawerHeader(
              isDarkMode: isDarkMode,
              onClose: () => Navigator.of(context).pop(),
            ),

// =====================================================
// CONTENIDO
// =====================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  20,
                ),
                children: [

// =================================================
// PRINCIPAL
// =================================================

                  _SectionTitle(
                    title: 'PRINCIPAL',
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 8),

                  _MenuContainer(
                    color: surfaceColor,
                    child: Column(
                      children: [

                        _DrawerItem(
                          icon: Icons.home_rounded,
                          title: 'Inicio',
                          subtitle: 'Panel principal',
                          isDarkMode: isDarkMode,
                          onTap: () {
                            _navigate(
                              context,
                              AppRoutes.home,
                            );
                          },
                        ),

                        if (canProducts)
                          _DrawerItem(
                            icon: Icons.inventory_2_rounded,
                            title: 'Productos',
                            subtitle: 'Productos e inventario',
                            isDarkMode: isDarkMode,
                            onTap: () {
                              _navigate(
                                context,
                                AppRoutes.product,
                              );
                            },
                          ),
                      ],
                    ),
                  ),

// =================================================
// OPERACIONES
// =================================================

                  if (canOrders ||
                      canSales ||
                      canCashSession) ...[

                    const SizedBox(height: 24),

                    _SectionTitle(
                      title: 'OPERACIONES',
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 8),

                    _MenuContainer(
                      color: surfaceColor,
                      child: Column(
                        children: [

                          if (canOrders)
                            _DrawerItem(
                              icon: Icons.shopping_bag_rounded,
                              title: 'Órdenes',
                              subtitle: 'Gestión de pedidos',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.orders,
                                );
                              },
                            ),

                          if (canSales)
                            _DrawerItem(
                              icon: Icons.receipt_long_rounded,
                              title: 'Ventas',
                              subtitle: 'Registro de ventas',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.sales,
                                );
                              },
                            ),

                          if (canCashSession)
                            _DrawerItem(
                              icon: Icons.point_of_sale_rounded,
                              title: 'Caja',
                              subtitle: 'Apertura, cierre e historial',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.cashSession,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],

// =================================================
// CONTROL
// =================================================

                  if (canReports ||
                      canInventoryCount) ...[

                    const SizedBox(height: 24),

                    _SectionTitle(
                      title: 'CONTROL',
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 8),

                    _MenuContainer(
                      color: surfaceColor,
                      child: Column(
                        children: [

                          if (canReports)
                            _DrawerItem(
                              icon: Icons.bar_chart_rounded,
                              title: 'Reportes',
                              subtitle: 'Indicadores y resultados',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.reports,
                                );
                              },
                            ),

                          if (canInventoryCount)
                            _DrawerItem(
                              icon: Icons.fact_check_rounded,
                              title: 'Conteo diario',
                              subtitle: 'Control de existencias',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.inventoryCount,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],

// =================================================
// ADMINISTRACIÓN
// =================================================

                  if (canCategories ||
                      canUsers ||
                      canRoles) ...[

                    const SizedBox(height: 24),

                    _SectionTitle(
                      title: 'ADMINISTRACIÓN',
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 8),

                    _MenuContainer(
                      color: surfaceColor,
                      child: Column(
                        children: [

                          if (canCategories)
                            _DrawerItem(
                              icon: Icons.category_rounded,
                              title: 'Categorías',
                              subtitle: 'Organización de productos',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.categories,
                                );
                              },
                            ),

                          if (canUsers)
                            _DrawerItem(
                              icon: Icons.people_alt_rounded,
                              title: 'Usuarios',
                              subtitle: 'Gestión de usuarios',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.users,
                                );
                              },
                            ),

                          if (canRoles)
                            _DrawerItem(
                              icon:
                              Icons.admin_panel_settings_rounded,
                              title: 'Roles y permisos',
                              subtitle: 'Control de accesos',
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _navigate(
                                  context,
                                  AppRoutes.roles,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

// =====================================================
// FOOTER
// =====================================================

            _DrawerFooter(
              isDarkMode: isDarkMode,
              onSignOut: () => _confirmSignOut(context),
            ),
          ],
        ),
      ),
    );
  }

// ===============================================================
// NAVEGACIÓN
// ===============================================================

  void _navigate(
      BuildContext context,
      String route,
      ) {
    Navigator.pop(context);

    Navigator.pushReplacementNamed(
      context,
      route,
    );
  }
}

// =================================================================
// HEADER
// =================================================================

class _DrawerHeader extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onClose;

  const _DrawerHeader({
    required this.isDarkMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        16,
        18,
      ),
      child: Row(
        children: [

// Logo / identidad
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  "D'Primera",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDarkMode
                        ? Colors.white
                        : AppColors.dark,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Sistema de gestión',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          Material(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onClose,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: isDarkMode
                      ? Colors.white70
                      : AppColors.dark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// TÍTULO DE SECCIÓN
// =================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDarkMode;

  const _SectionTitle({
    required this.title,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        bottom: 2,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: isDarkMode
              ? Colors.white38
              : Colors.black38,
        ),
      ),
    );
  }
}

// =================================================================
// CONTENEDOR DE GRUPO
// =================================================================

class _MenuContainer extends StatelessWidget {
  final Color color;
  final Widget child;

  const _MenuContainer({
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness ==
              Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.045),
        ),
        boxShadow: Theme.of(context).brightness ==
            Brightness.dark
            ? null
            : [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: child,
    );
  }
}

// =================================================================
// ITEM
// =================================================================

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: Row(
            children: [

// ICONO
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.09),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 21,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 13),

// TEXTO
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.dark,
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.1,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode
                              ? Colors.white38
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDarkMode
                    ? Colors.white24
                    : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// FOOTER
// =================================================================

class _DrawerFooter extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onSignOut;

  const _DrawerFooter({
    required this.isDarkMode,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkBody
            : const Color(0xFFF7F7F8),
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        children: [

          Material(
            color: isDarkMode
                ? AppColors.dark
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onSignOut,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Row(
                  children: [

                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.09),
                        borderRadius:
                        BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.dark,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDarkMode
                          ? Colors.white24
                          : Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          Text(
            "D'Primera  •  Sistema de gestión",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? Colors.white24
                  : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// CERRAR SESIÓN
// =================================================================

Future<void> _confirmSignOut(
    BuildContext context,
    ) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color:
          AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.logout_rounded,
          color: AppColors.primary,
        ),
      ),
      title: const Text(
        '¿Cerrar sesión?',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Tendrás que ingresar nuevamente para acceder al sistema.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          onPressed: () =>
              Navigator.pop(dialogContext, true),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await getIt<SessionCoordinator>().signOut();
  }
}
