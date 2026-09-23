import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/profile/domain/entities/user_profile.dart';
import 'package:app_movil_sistema/features/profile/domain/usecases/profile_usecases.dart';
import 'package:app_movil_sistema/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProfileCubit(
      getIt<GetProfileUseCase>(),
      getIt<UpdateProfilePasswordUseCase>(),
    )..load(),
    child: const _ProfileView(),
  );
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submitPassword() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileCubit>().changePassword(
      oldPassword: _oldPassword.text,
      newPassword: _newPassword.text,
      confirmationPassword: _confirmation.text,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ProfileCubit, ProfileState>(
    listener: (context, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
        );
        context.read<ProfileCubit>().clearMessage();
      }
      if (state.passwordUpdated) {
        _oldPassword.clear();
        _newPassword.clear();
        _confirmation.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada correctamente')),
        );
        context.read<ProfileCubit>().clearMessage();
      }
    },
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Actualizar datos',
            onPressed: state.isLoading
                ? null
                : () => context.read<ProfileCubit>().load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && state.profile == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => context.read<ProfileCubit>().load(),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (state.profile != null) ...[
                      _Header(profile: state.profile!),
                      const SizedBox(height: 20),
                      _InformationCard(profile: state.profile!),
                    ] else
                      _Unavailable(
                        onRetry: () => context.read<ProfileCubit>().load(),
                      ),
                    const SizedBox(height: 20),
                    _PasswordCard(
                      formKey: _formKey,
                      oldPassword: _oldPassword,
                      newPassword: _newPassword,
                      confirmation: _confirmation,
                      hidePassword: _hidePassword,
                      isUpdating: state.isUpdatingPassword,
                      onVisibilityChanged: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      onSubmit: _submitPassword,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile.fullName ?? 'Usuario';
    final foreground = theme.colorScheme.onPrimaryContainer;
    final initials = name.trim().isEmpty
        ? '?'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0])
              .join();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: foreground.withValues(alpha: .12),
            backgroundImage: profile.avatarUrl?.isNotEmpty == true
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: profile.avatarUrl?.isNotEmpty == true
                ? null
                : Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ).copyWith(color: foreground),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foreground,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: TextStyle(color: foreground.withValues(alpha: .78)),
          ),
          if (profile.roles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: profile.roles
                  .map(
                    (role) => Chip(
                      label: Text(
                        role.replaceFirst('ROLE_', '').replaceAll('_', ' '),
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ).copyWith(color: theme.colorScheme.onPrimary),
                      backgroundColor: theme.colorScheme.primary,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) => _Card(
    title: 'Datos personales',
    child: Column(
      children: [
        _Info(
          icon: Icons.email_outlined,
          label: 'Correo',
          value: profile.email,
        ),
        if (profile.document?.isNotEmpty == true)
          _Info(
            icon: Icons.badge_outlined,
            label: profile.documentTypeName ?? 'Documento',
            value: profile.document!,
          ),
        if (profile.phone?.isNotEmpty == true)
          _Info(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: profile.phone!,
          ),
        if (profile.address?.isNotEmpty == true)
          _Info(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: profile.address!,
          ),
        const SizedBox(height: 6),
        Text(
          'La edición de estos datos estará disponible próximamente.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({
    required this.formKey,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmation,
    required this.hidePassword,
    required this.isUpdating,
    required this.onVisibilityChanged,
    required this.onSubmit,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController oldPassword;
  final TextEditingController newPassword;
  final TextEditingController confirmation;
  final bool hidePassword;
  final bool isUpdating;
  final VoidCallback onVisibilityChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => _Card(
    title: 'Seguridad de la cuenta',
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actualiza tu contraseña para proteger tu acceso.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          _field(oldPassword, 'Contraseña actual'),
          const SizedBox(height: 14),
          _field(
            newPassword,
            'Nueva contraseña',
            validator: (value) => value == null || value.length < 6
                ? 'Mínimo 6 caracteres'
                : null,
          ),
          const SizedBox(height: 14),
          _field(
            confirmation,
            'Confirmar nueva contraseña',
            validator: (value) => value != newPassword.text
                ? 'Las contraseñas no coinciden'
                : null,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isUpdating ? null : onSubmit,
              icon: isUpdating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_reset_rounded),
              label: Text(
                isUpdating ? 'Actualizando...' : 'Actualizar contraseña',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    obscureText: hidePassword,
    validator:
        validator ??
        (value) =>
            value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        onPressed: onVisibilityChanged,
        icon: Icon(
          hidePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Icon(Icons.person_off_outlined, size: 34),
          const SizedBox(height: 8),
          const Text('No se pudieron cargar tus datos.'),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}
