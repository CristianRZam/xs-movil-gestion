import 'package:app_movil_sistema/core/app_version/app_version_service.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key, required this.status, required this.continuePage});
  final AppVersionStatus status;
  final Widget continuePage;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      status.updateRequired
                          ? Icons.system_update_alt_rounded
                          : Icons.new_releases_outlined,
                      color: AppColors.primary,
                      size: 58,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      status.updateRequired
                          ? 'Actualización necesaria'
                          : 'Hay una actualización disponible',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status.message,
                      textAlign: TextAlign.center,
                    ),
                    if (status.latestVersion != null) ...[
                      const SizedBox(height: 8),
                      Text('Versión disponible: ${status.latestVersion}'),
                    ],
                    const SizedBox(height: 24),
                    if (status.downloadUrl?.isNotEmpty == true)
                      FilledButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse(status.downloadUrl!),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Actualizar aplicación'),
                      ),
                    if (!status.updateRequired) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => continuePage),
                        ),
                        child: const Text('Continuar con esta versión'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
