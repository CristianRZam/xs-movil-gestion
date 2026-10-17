import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/role/domain/entities/role.dart';
import 'package:app_movil_sistema/features/role/domain/usecases/role_usecases.dart';
import 'package:app_movil_sistema/features/role/presentation/bloc/role_cubit.dart';
import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs_responsive_body.dart';
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
      getIt<CreateRoleUseCase>(),
      getIt<UpdateRoleUseCase>(),
      getIt<UpdateRoleStatusUseCase>(),
    )..loadRoles(),
    child: const _RoleView(),
  );
}

class _RoleView extends StatelessWidget {
  const _RoleView();

  Future<void> _openRoleForm(BuildContext context, [AppRole? role]) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => BlocProvider.value(
          value: context.read<RoleCubit>(),
          child: _RoleForm(role: role),
        ),
      );

  Future<void> _toggle(BuildContext context, AppRole role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(role.active ? 'Desactivar rol' : 'Activar rol'),
        content: Text('¿Deseas cambiar el estado de ${role.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<RoleCubit>().toggle(role);
    }
  }

  Future<void> _openPermissions(BuildContext context, AppRole role) async {
    if (!getIt<AccessControl>().allows(AppCapability.viewRolePermissions)) {
      return;
    }
    final cubit = context.read<RoleCubit>();
    await cubit.loadPermissions(role.id);
    if (!context.mounted || cubit.state.permissions == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
        // Un 403 ya activa el toast global de autorización. El mapper usa
        // este texto genérico cuando la respuesta no trae mensaje, así que
        // no se debe duplicar con otro toast.
        if (state.errorMessage != 'Error desconocido') {
          FlashMessage.show(
            context,
            type: FlashMessageType.error,
            title: 'No se pudo completar la operación',
            message: state.errorMessage!,
          );
        }
        context.read<RoleCubit>().clearFeedback();
      }
      if (state.saved && state.success != null) {
        if (state.success == RoleSuccess.created ||
            state.success == RoleSuccess.updated) {
          Navigator.of(context).maybePop();
        }
        final message = switch (state.success!) {
          RoleSuccess.created => 'El rol fue creado correctamente.',
          RoleSuccess.updated => 'Los cambios del rol fueron guardados.',
          RoleSuccess.activated => 'El rol fue activado correctamente.',
          RoleSuccess.deactivated => 'El rol fue desactivado correctamente.',
        };
        FlashMessage.show(
          context,
          type: FlashMessageType.success,
          title: 'Operación completada',
          message: message,
        );
        context.read<RoleCubit>()
          ..clearFeedback()
          ..loadRoles();
      }
    },
    builder: (context, state) => Scaffold(
      appBar: const XsAppBar(title: 'Roles y permisos', backIcon: false),
      endDrawer: const XsDrawer(),
      floatingActionButton: getIt<AccessControl>().allows(AppCapability.createRoles)
          ? FloatingActionButton.extended(
              onPressed: state.isSaving ? null : () => _openRoleForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo rol'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<RoleCubit>().loadRoles(),
        child: XsResponsiveBody(
          maxWidth: 720,
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
                    child: _RoleCard(
                      role: role,
                      onPermissions: () => _openPermissions(context, role),
                      onEdit: () => _openRoleForm(context, role),
                      onStatus: () => _toggle(context, role),
                    ),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.onPermissions,
    required this.onEdit,
    required this.onStatus,
  });

  final AppRole role;
  final VoidCallback onPermissions;
  final VoidCallback onEdit;
  final VoidCallback onStatus;

  @override
  Widget build(BuildContext context) {
    final access = getIt<AccessControl>();
    final canViewPermissions = access.allows(AppCapability.viewRolePermissions);
    final canEdit = access.allows(AppCapability.editRoles);
    final statusColor = role.active ? AppColors.success : AppColors.danger;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(child: const Icon(Icons.badge_outlined)),
      title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        role.description?.trim().isNotEmpty == true
            ? role.description!
            : 'Sin descripción',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: role.active ? 'Activo' : 'Inactivo',
            child: Icon(
              role.active
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: statusColor,
              semanticLabel: role.active ? 'Activo' : 'Inactivo',
            ),
          ),
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) => value == 'edit' ? onEdit() : onStatus(),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(
                  value: 'status',
                  child: Text(role.active ? 'Desactivar' : 'Activar'),
                ),
              ],
            )
          else if (canViewPermissions)
            const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: canViewPermissions ? onPermissions : null,
    );
  }
}

class _RoleForm extends StatefulWidget {
  const _RoleForm({this.role});
  final AppRole? role;

  @override
  State<_RoleForm> createState() => _RoleFormState();
}

class _RoleFormState extends State<_RoleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.role?.name);
    _description = TextEditingController(text: widget.role?.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<RoleCubit>().save(
      RoleRequest(
        id: widget.role?.id,
        name: _name.text,
        description: _description.text,
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
      child: SingleChildScrollView(
        child: BlocBuilder<RoleCubit, RoleState>(
          builder: (context, state) => Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.role == null ? 'Nuevo rol' : 'Editar rol',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  maxLength: 255,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del rol',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.trim().isEmpty != false
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _description,
                  maxLength: 255,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.isSaving ? null : _save,
                    icon: state.isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      state.isSaving
                          ? 'Guardando...'
                          : widget.role == null
                          ? 'Crear rol'
                          : 'Guardar cambios',
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: BlocConsumer<RoleCubit, RoleState>(
        listener: (context, state) {
          if (state.saved) {
            FlashMessage.show(
              context,
              type: FlashMessageType.success,
              title: 'Permisos actualizados',
              message: 'Los permisos del rol fueron guardados correctamente.',
            );
            Navigator.of(context).pop();
            context.read<RoleCubit>().clearFeedback();
          }
        },
        builder: (context, state) => SafeArea(
          top: false,
          child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Permisos del rol',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                widget.data.role.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
                                    // `name` is the internal permission code
                                    // (for example, VIEW_PRODUCT). Administrators
                                    // only need the human-readable description.
                                    title: Text(
                                      permission.description?.trim().isNotEmpty == true
                                          ? permission.description!
                                          : 'Sin descripción disponible',
                                    ),
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
