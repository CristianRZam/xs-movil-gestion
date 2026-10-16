import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Botón compacto y consistente para abrir filtros en pantallas pequeñas.
class XsFilterButton extends StatelessWidget {
  const XsFilterButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Mostrar filtros',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.white38,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? .32 : .22,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
