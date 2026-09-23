import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProductSearch extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;

  final TextEditingController controller;

  const ProductSearch({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,

      textInputAction: TextInputAction.search,
      onSubmitted: (value) => onSubmitted?.call(value.trim()),

      decoration: InputDecoration(
        hintText: "Buscar producto...",

        prefixIcon: const Icon(Icons.search),

        filled: true,

        fillColor: isDark ? AppColors.dark : AppColors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: const BorderSide(color: AppColors.grey, width: 1.5),
        ),
      ),
    );
  }
}
