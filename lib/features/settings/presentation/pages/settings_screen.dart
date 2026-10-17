import 'package:app_movil_sistema/core/authorization/permission_sync_service.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/core/theme/theme_cubit.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs_responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_movil_sistema/routes/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncingPermissions = false;

  Future<void> _syncPermissions() async {
    if (_isSyncingPermissions) return;
    setState(() => _isSyncingPermissions = true);
    final synced = await getIt<PermissionSyncService>().refresh(force: true);
    if (!mounted) return;
    setState(() => _isSyncingPermissions = false);

    FlashMessage.show(
      context,
      type: synced ? FlashMessageType.success : FlashMessageType.error,
      title: synced ? 'Permisos actualizados' : 'No se pudo actualizar',
      message: synced
          ? 'Tus accesos se sincronizaron con el servidor.'
          : 'Verifica tu conexión e inténtalo nuevamente.',
      position: FlashMessagePosition.top,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Volver a Inicio',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (_) => false,
          ),
        ),
      ),
      body: SafeArea(
        child: XsResponsiveBody(
          child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Apariencia', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  final isDark = themeMode == ThemeMode.dark;

                  return SwitchListTile(
                    secondary: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                    ),
                    title: const Text('Modo oscuro'),
                    subtitle: Text(
                      isDark ? 'Tema oscuro activado' : 'Tema claro activado',
                    ),
                    value: isDark,
                    onChanged: (enabled) {
                      final themeCubit = context.read<ThemeCubit>();

                      if (enabled) {
                        themeCubit.setDarkTheme();
                      } else {
                        themeCubit.setLightTheme();
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Text('Acceso', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _PermissionSyncCard(
              isDark: isDark,
              isLoading: _isSyncingPermissions,
              onTap: _syncPermissions,
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _PermissionSyncCard extends StatelessWidget {
  const _PermissionSyncCard({
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });

  final bool isDark;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final surface = isDark ? AppColors.darkElevatedSurface : AppColors.white;
    final border = isDark
        ? AppColors.darkSelectorBorder
        : AppColors.primary.withValues(alpha: .16);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .055),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? .34 : .22,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sync_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actualizar permisos',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Sincroniza tus accesos con el servidor.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        color: isDark
                            ? AppColors.dangerLight
                            : AppColors.primary,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
