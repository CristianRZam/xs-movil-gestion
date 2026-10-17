import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Selector reutilizable para opciones mutuamente excluyentes.
///
/// Solo resuelve la presentaciÃ³n: el estado y la acciÃ³n permanecen en la
/// pantalla que lo utiliza.
class XsSegmentedTab<T> {
  const XsSegmentedTab({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class XsSegmentedTabs<T> extends StatelessWidget {
  const XsSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  final List<XsSegmentedTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;
    final height = compact ? 48.0 : 52.0;

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSelectorSurface
            : AppColors.primary.withValues(alpha: .065),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkSelectorBorder
              : AppColors.primary.withValues(alpha: .16),
        ),
      ),
      child: Row(
        children: tabs
            .map(
              (tab) => Expanded(
                child: _XsSegmentedTabButton(
                  tab: tab,
                  selected: tab.value == selected,
                  compact: compact,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                  onTap: () => onSelected(tab.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _XsSegmentedTabButton<T> extends StatelessWidget {
  const _XsSegmentedTabButton({
    required this.tab,
    required this.selected,
    required this.compact,
    required this.inactiveColor,
    required this.isDark,
    required this.onTap,
  });

  final XsSegmentedTab<T> tab;
  final bool selected;
  final bool compact;
  final Color inactiveColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: tab.label,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? AppColors.darkSelected : AppColors.primary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? .28 : .22,
                        ),
                        blurRadius: isDark ? 10 : 7,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab.icon,
                    size: compact ? 16 : 18,
                    color: selected ? AppColors.white : inactiveColor,
                  ),
                  SizedBox(width: compact ? 4 : 7),
                  Flexible(
                    child: Text(
                      tab.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? AppColors.white : inactiveColor,
                        fontSize: compact ? 11 : 12,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
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
