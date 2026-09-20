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
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
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

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.home,
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

                  _DrawerItem(
                    icon: Icons.inventory_2_rounded,
                    title: '01 / Productos',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.product,
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

                  _DrawerItem(
                    icon: Icons.shopping_cart_rounded,
                    title: '02 / Ventas',
                    isDarkMode: isDarkMode,
                    onTap: () {},
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
                    title: '03 / Caja',
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

                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    title: '04 / Reportes',
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Pie con logo
          Container(
            color: isDarkMode ? AppColors.dark : AppColors.primary,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: const Text(
              '© empresa',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
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
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDarkMode
            ? AppColors.white
            : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: isDarkMode
              ? AppColors.white
              : AppColors.dark,
        ),
      ),
      onTap: onTap,
    );
  }
}