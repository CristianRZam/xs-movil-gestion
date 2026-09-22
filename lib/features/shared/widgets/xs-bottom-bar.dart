import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';

class XsBottomBar extends StatelessWidget {
  const XsBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.dark : AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Configuración',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
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
                      onPressed: () {
                        Navigator.pop(dialogContext, false);
                      },
                      child: const Text('Cancelar'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(dialogContext, true);
                      },
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );

              if (confirmed != true || !context.mounted) return;

              await getIt<SessionCoordinator>().signOut();
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
