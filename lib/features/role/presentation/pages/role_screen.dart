import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/role/domain/entities/role.dart';
import 'package:app_movil_sistema/features/role/domain/usecases/role_usecases.dart';
import 'package:app_movil_sistema/features/role/presentation/bloc/role_cubit.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => RoleCubit(
      getIt<GetRolesUseCase>(),
      getIt<GetRolePermissionsUseCase>(),
      getIt<UpdateRolePermissionsUseCase>(),
    )..loadRoles(),
    child: const _RoleView(),
  );
}

class _RoleView extends StatelessWidget {
  const _RoleView();

  Future<void> _openPermissions(BuildContext context, AppRole role) async {
    final cubit = context.read<RoleCubit>();
    await cubit.loadPermissions(role.id);
    if (!context.mounted || cubit.state.permissions == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _RolePermissionsSheet(data: cubit.state.permissions!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<RoleCubit, RoleState>(
    listener: (context, state) {
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
        context.read<RoleCubit>().clearFeedback();
      }
    },
    builder: (context, state) => Scaffold(
      appBar: const XsAppBar(title: 'Roles y permisos', backIcon: false),
      endDrawer: const XsDrawer(),
      body: RefreshIndicator(
        onRefresh: () => context.read<RoleCubit>().loadRoles(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            Text(
              'Roles y permisos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecciona un rol para definir las acciones disponibles para sus usuarios.',
            ),
            const SizedBox(height: 20),
            if (state.status == RoleStatus.loading && state.roles.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.roles.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: Text('No se encontraron roles.')),
              )
            else
              ...state.roles.map(
                (role) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          role.name == 'SUPER_ADMIN'
                              ? Icons.admin_panel_settings_outlined
                              : Icons.badge_outlined,
                        ),
                      ),
                      title: Text(
                        role.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        role.description?.trim().isNotEmpty == true
                            ? role.description!
                            : 'Sin descripción',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(role.active ? 'Activo' : 'Inactivo'),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      onTap: () => _openPermissions(context, role),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _RolePermissionsSheet extends StatefulWidget {
  const _RolePermissionsSheet({required this.data});
  final RolePermissions data;

  @override
  State<_RolePermissionsSheet> createState() => _RolePermissionsSheetState();
}

class _RolePermissionsSheetState extends State<_RolePermissionsSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.data.assignedPermissionIds};
  }

  Map<String, List<AppPermission>> get _grouped {
    final groups = <String, List<AppPermission>>{};
    for (final permission in widget.data.allPermissions) {
      (groups[permission.module?.trim().isNotEmpty == true
              ? permission.module!
              : 'Otros'] ??= [])
          .add(permission);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final canAssign = getIt<AccessControl>().allows(
      AppCapability.assignRolePermissions,
    );
    return Scaffold(
      appBar: XsAppBar(
        title: 'Permisos del rol',
        onMenuPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: BlocConsumer<RoleCubit, RoleState>(
        listener: (context, state) {
          if (state.saved) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permisos actualizados correctamente.')),
            );
            context.read<RoleCubit>().clearFeedback();
          }
        },
        builder: (context, state) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              Text(
                widget.data.role.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                canAssign
                    ? 'Marca las acciones que podrá realizar este rol.'
                    : 'Permisos asignados a este rol.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: _grouped.entries
                      .map(
                        (entry) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: ExpansionTile(
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text('${entry.value.length} permiso(s)'),
                            children: entry.value
                                .map(
                                  (permission) => CheckboxListTile(
                                    value: _selected.contains(permission.id),
                                    onChanged: canAssign
                                        ? (selected) => setState(() {
                                            if (selected == true) {
                                              _selected.add(permission.id);
                                            } else {
                                              _selected.remove(permission.id);
                                            }
                                          })
                                        : null,
                                    title: Text(permission.name),
                                    subtitle: permission.description?.isNotEmpty == true
                                        ? Text(permission.description!)
                                        : null,
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (canAssign) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () => context.read<RoleCubit>().savePermissions(
                            widget.data.role.id,
                            _selected,
                          ),
                    icon: state.isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(state.isSaving ? 'Guardando...' : 'Guardar permisos'),
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
}
