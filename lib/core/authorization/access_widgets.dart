import 'package:flutter/material.dart';
import '../service_locator.dart';
import 'access_control.dart';

/// Reusable equivalent of the web's permission directive.
class AccessVisibility extends StatelessWidget {
  const AccessVisibility({
    super.key,
    required this.capability,
    required this.child,
  });
  final AppCapability capability;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final access = getIt<AccessControl>();
    return ListenableBuilder(
      listenable: access,
      builder: (_, _) =>
          access.allows(capability) ? child : const SizedBox.shrink(),
    );
  }
}

/// Lazy builder: denied screens never initialize BLoCs or load their data.
class AccessGuard extends StatelessWidget {
  const AccessGuard({
    super.key,
    required this.capability,
    required this.builder,
  });
  final AppCapability capability;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final access = getIt<AccessControl>();
    return ListenableBuilder(
      listenable: access,
      builder: (context, _) {
        if (access.allows(capability)) return builder(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Acceso restringido')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    access.isAuthenticated
                        ? 'Tu rol no tiene acceso a esta pantalla.'
                        : 'Tu sesión no está disponible. Inicia sesión nuevamente.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          access.allows(AppCapability.operate)
                              ? '/home'
                              : '/login',
                          (_) => false,
                        ),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
