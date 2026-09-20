import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';


class XsPaginator extends StatelessWidget {

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;


  const XsPaginator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });


  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;


    if (totalPages <= 1) {
      return const SizedBox();
    }


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        _PageButton(
          icon: Icons.chevron_left,
          enabled: currentPage > 0,
          onTap: () {
            onPageChanged(currentPage - 1);
          },
        ),


        const SizedBox(width: 8),


        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2A2F3A)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${currentPage + 1} / $totalPages",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white
                  : AppColors.textLight,
            ),
          ),
        ),


        const SizedBox(width: 8),


        _PageButton(
          icon: Icons.chevron_right,
          enabled: currentPage < totalPages - 1,
          onTap: () {
            onPageChanged(currentPage + 1);
          },
        ),

      ],
    );
  }
}



class _PageButton extends StatelessWidget {

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;


  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;


    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(50),

      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : isDark
              ? const Color(0xFF333842)
              : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),

        child: Icon(
          icon,
          size: 22,
          color: enabled
              ? Colors.white
              : Colors.grey,
        ),
      ),
    );
  }
}