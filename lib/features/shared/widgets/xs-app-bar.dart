import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-text.dart';
import 'package:flutter/material.dart';

class XsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final bool backIcon;

  const XsAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.backIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.dark : AppColors.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6,
            )
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (backIcon) // Solo se dibuja si es true
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                        size: 30,
                      ),
                    ),
                  if (backIcon) const SizedBox(width: 8),
                  XsText(
                    text: title,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.left,
                    color: AppColors.white,
                    useDarkModeColor: true,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: onMenuPressed ??
                        () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
}
