import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';
import 'package:app_movil_sistema/features/user/domain/usecases/user_usecases.dart';
import 'package:app_movil_sistema/features/user/presentation/bloc/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => UserCubit(
      getIt<GetUsersUseCase>(),
      getIt<GetUserFormUseCase>(),
      getIt<CreateUserUseCase>(),
      getIt<UpdateUserUseCase>(),
      getIt<UpdateUserStatusUseCase>(),
    )..load(),
    child: const _UserView(),
  );
}

class _UserView extends StatefulWidget {
  const _UserView();
  @override
  State<_UserView> createState() => _UserViewState();
}

class _UserViewState extends State<_UserView> {
  final _search = TextEditingController();
  bool? _status;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => context.read<UserCubit>().load(
    UserFilter(
      query: _search.text.trim().isEmpty ? null : _search.text,
      status: _status,
    ),
  );
  Future<void> _openForm([AppUser? user]) async {
    final cubit = context.read<UserCubit>();
    await cubit.loadForm(user?.id);
    if (!mounted || cubit.state.form == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _UserForm(data: cubit.state.form!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<UserCubit, UserState>(
    listener: (context, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!)));
        context.read<UserCubit>().clearFeedback();
      }
      if (state.saved) {
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado correctamente')),
        );
        context.read<UserCubit>()
          ..clearFeedback()
          ..load();
      }
    },
    builder: (context, state) => Scaffold(
      appBar: const XsAppBar(title: 'Usuarios', backIcon: false),
      endDrawer: const XsDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.saving ? null : () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo usuario'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<UserCubit>().load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
          children: [
            Text(
              'Usuarios',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Administra las cuentas y accesos del negocio.'),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _load(),
                    decoration: const InputDecoration(
                      hintText: 'Buscar usuario, nombre o correo',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _showStatusFilter(context),
                  icon: Badge(
                    isLabelVisible: _status != null,
                    child: const Icon(Icons.tune_rounded),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _search.clear();
                    setState(() => _status = null);
                    _load();
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (state.status == UserStatus.loading && state.users.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.users.isEmpty)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: Text('No se encontraron usuarios.')),
              )
            else
              ...state.users.map(
                (u) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UserCard(
                    user: u,
                    onEdit: () => _openForm(u),
                    onStatus: () => _toggle(u),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  Future<void> _showStatusFilter(BuildContext context) async {
    final value = await showModalBottomSheet<bool?>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 8,
            children: [
              for (final v in <bool?>[null, true, false])
                ChoiceChip(
                  label: Text(
                    v == null
                        ? 'Todos'
                        : v
                        ? 'Activos'
                        : 'Inactivos',
                  ),
                  selected: _status == v,
                  onSelected: (_) => Navigator.pop(sheet, v),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _status = value);
    _load();
  }

  Future<void> _toggle(AppUser user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(user.active ? 'Desactivar usuario' : 'Activar usuario'),
        content: Text('¿Deseas cambiar el estado de ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) context.read<UserCubit>().toggle(user.id);
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onStatus,
  });
  final AppUser user;
  final VoidCallback onEdit;
  final VoidCallback onStatus;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Text(
            user.fullName.isEmpty
                ? '?'
                : user.fullName.substring(0, 1).toUpperCase(),
          ),
        ),
        title: Text(
          user.fullName.isEmpty ? user.username : user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '@${user.username} · ${user.email}\n${user.roleNames.join(', ')}',
        ),
        isThreeLine: user.roleNames.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onStatus(),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(
              value: 'status',
              child: Text(user.active ? 'Desactivar' : 'Activar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserForm extends StatefulWidget {
  const _UserForm({required this.data});
  final UserFormData data;
  @override
  State<_UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<_UserForm> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _username,
      _email,
      _document,
      _name,
      _phone,
      _address;
  int? _type;
  late Set<int> _roles;
  @override
  void initState() {
    super.initState();
    final u = widget.data.user;
    _username = TextEditingController(text: u?.username);
    _email = TextEditingController(text: u?.email);
    _document = TextEditingController(text: u?.document);
    _name = TextEditingController(text: u?.fullName);
    _phone = TextEditingController(text: u?.phone);
    _address = TextEditingController(text: u?.address);
    _type = u?.typeDocument;
    _roles = {...?u?.roleIds};
  }

  @override
  void dispose() {
    for (final c in [_username, _email, _document, _name, _phone, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!(_key.currentState?.validate() ?? false) ||
        _type == null ||
        _roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa los campos obligatorios y selecciona un rol.',
          ),
        ),
      );
      return;
    }
    context.read<UserCubit>().save(
      UserRequest(
        id: widget.data.user?.id,
        username: _username.text,
        email: _email.text,
        typeDocument: _type!,
        document: _document.text,
        fullName: _name.text,
        phone: _phone.text,
        address: _address.text,
        roleIds: _roles.toList(),
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
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.user == null ? 'Nuevo usuario' : 'Editar usuario',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de documento',
                  border: OutlineInputBorder(),
                ),
                items: widget.data.documentTypes
                    .where((x) => x.active || x.id == _type)
                    .map(
                      (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v),
                validator: (v) => v == null ? 'Seleccione un tipo' : null,
              ),
              const SizedBox(height: 10),
              _field(_document, 'Documento', 20),
              _field(_name, 'Nombre completo', 255),
              _field(_phone, 'Teléfono', 50, required: false),
              _field(_address, 'Dirección', 255, required: false),
              Text('Roles', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: widget.data.roles
                    .where((r) => r.active || _roles.contains(r.id))
                    .map(
                      (r) => FilterChip(
                        label: Text(r.name),
                        selected: _roles.contains(r.id),
                        onSelected: (v) => setState(() {
                          if (v) {
                            _roles.add(r.id);
                          } else {
                            _roles.remove(r.id);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              _field(_username, 'Nombre de usuario', 50),
              _field(_email, 'Correo electrónico', 100, email: true),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    widget.data.user == null
                        ? 'Crear usuario'
                        : 'Guardar cambios',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _field(
    TextEditingController c,
    String label,
    int max, {
    bool required = true,
    bool email = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: c,
      maxLength: max,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (required && t.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (email &&
            t.isNotEmpty &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
          return 'Ingrese un correo válido';
        }
        return null;
      },
    ),
  );
}
