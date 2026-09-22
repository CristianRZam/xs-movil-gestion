import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Capa global de carga. Se inserta en el overlay raíz para cubrir incluso
/// diálogos, bottom sheets y cualquier interacción de la pantalla actual.
class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  OverlayEntry? _entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) _sync();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.isLoading && _entry == null) {
        _entry = OverlayEntry(
          builder: (_) => Positioned.fill(
            child: Material(
              color: Colors.black54,
              child: AbsorbPointer(
                absorbing: true,
                child: Center(
                  child: Semantics(
                    label: 'Cargando, espere por favor',
                    child: Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 82,
                            height: 82,
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                              color: AppColors.grey.withOpacity(.9),
                            ),
                          ),
                          ClipOval(
                            child: Image.asset(
                              'assets/images/icono_sin_fondo.webp',
                              width: 62,
                              height: 62,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        Overlay.of(context, rootOverlay: true).insert(_entry!);
      } else if (!widget.isLoading) {
        _remove();
      }
    });
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
