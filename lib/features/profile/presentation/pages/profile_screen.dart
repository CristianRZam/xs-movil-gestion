import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await ApiClient().dio.put(
        '/profile/update-password',
        data: {
          'oldPassword': _oldPassword.text,
          'newPassword': _newPassword.text,
          'confirmationPassword': _confirmation.text,
        },
      );
      final api = ApiResponse<bool>.fromJson(response.data, (value) => value as bool? ?? false);
      if (!api.success) throw Exception(api.message);
      _oldPassword.clear();
      _newPassword.clear();
      _confirmation.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada correctamente')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo cambiar la contraseña: $error'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.tertiary]),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(radius: 34, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 38)),
                    SizedBox(height: 12),
                    Text('Seguridad de la cuenta', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Actualiza tu contraseña para proteger tu acceso', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: theme.dividerColor)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cambiar contraseña', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('Usa una contraseña segura que no compartas con nadie.', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 22),
                        _passwordField(_oldPassword, 'Contraseña actual'),
                        const SizedBox(height: 14),
                        _passwordField(_newPassword, 'Nueva contraseña', validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null),
                        const SizedBox(height: 14),
                        _passwordField(_confirmation, 'Confirmar nueva contraseña', validator: (value) => value != _newPassword.text ? 'Las contraseñas no coinciden' : null),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _updatePassword,
                            icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_reset_rounded),
                            label: Text(_loading ? 'Actualizando...' : 'Actualizar contraseña'),
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                      ],
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

  Widget _passwordField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: _hidePassword,
      validator: validator ?? (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _hidePassword = !_hidePassword),
          icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
