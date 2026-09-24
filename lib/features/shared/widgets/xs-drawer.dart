import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-dash-line.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-text.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/routes/routes.dart';

class XsDrawer extends StatelessWidget {
  const XsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: isDarkMode ? AppColors.dark : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 40,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const XsText(
                  text: 'EmpreGestion',
                  fontSize: 24,
                  color: AppColors.white,
                  useDarkModeColor: true,
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 30), // margen izquierdo
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBody : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ListView(
                children: [
                  XsText(
                    text: '➤ MENÚ PRINCIPAL',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    useDarkModeColor: true,
                  ),

                  const SizedBox(height: 15),

                  _DrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Inicio',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                  ),

                  if (getIt<AccessControl>().allows(AppCapability.viewProducts))
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: DashedLine(
                        dashWidth: 6,
                        dashSpace: 5,
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),

                  if (getIt<AccessControl>().allows(AppCapability.viewProducts))
                    _DrawerItem(
                      icon: Icons.inventory_2_rounded,
                      title: 'Productos',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.product,
                        );
                      },
                    ),

                  if (getIt<AccessControl>().allows(AppCapability.viewProducts))
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: DashedLine(
                        dashWidth: 6,
                        dashSpace: 5,
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),

                  _DrawerItem(
                    icon: Icons.shopping_cart_rounded,
                    title: 'Órdenes',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, AppRoutes.orders);
                    },
                  ),

                  _DrawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Ventas',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, AppRoutes.sales);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: DashedLine(
                      dashWidth: 6,
                      dashSpace: 5,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),

                  _DrawerItem(
                    icon: Icons.point_of_sale_rounded,
                    title: 'Caja',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.cashSession,
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: DashedLine(
                      dashWidth: 6,
                      dashSpace: 5,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),

                  if (getIt<AccessControl>().allows(AppCapability.reports))
                    _DrawerItem(
                      icon: Icons.bar_chart_rounded,
                      title: 'Reportes',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.reports,
                        );
                      },
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: DashedLine(
                      dashWidth: 6,
                      dashSpace: 5,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),

                  if (getIt<AccessControl>().allows(
                    AppCapability.inventoryCount,
                  ))
                    _DrawerItem(
                      icon: Icons.inventory_rounded,
                      title: 'Conteo diario',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.inventoryCount,
                        );
                      },
                    ),

                  if (getIt<AccessControl>().allows(
                    AppCapability.manageCategories,
                  ))
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: DashedLine(
                        dashWidth: 6,
                        dashSpace: 5,
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),

                  if (getIt<AccessControl>().allows(
                    AppCapability.manageCategories,
                  ))
                    _DrawerItem(
                      icon: Icons.category_rounded,
                      title: 'Categorías',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.categories,
                        );
                      },
                    ),

                  if (getIt<AccessControl>().allows(AppCapability.manageUsers))
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: DashedLine(
                        dashWidth: 6,
                        dashSpace: 5,
                        height: 1,
                        color: Colors.grey,
                      ),
                    ),
                  if (getIt<AccessControl>().allows(AppCapability.manageUsers))
                    _DrawerItem(
                      icon: Icons.people_alt_rounded,
                      title: 'Usuarios',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.users,
                        );
                      },
                    ),
                  if (getIt<AccessControl>().allows(AppCapability.manageRoles))
                    _DrawerItem(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Roles y permisos',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, AppRoutes.roles);
                      },
                    ),
                ],
              ),
            ),
          ),

          // Acciones finales del panel
          Container(
            color: isDarkMode ? AppColors.dark : AppColors.primary,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(48, 12, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '© empresa',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.logout_rounded, color: Colors.red),
      title: const Text('¿Cerrar sesión?'),
      content: const Text(
        'Tendrás que ingresar nuevamente para acceder al sistema.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await getIt<SessionCoordinator>().signOut();
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          color: isDarkMode ? AppColors.white : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? AppColors.white : AppColors.dark,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
