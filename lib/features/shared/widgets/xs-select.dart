import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class XsSelect<T> extends StatelessWidget {
  final String? labelText;
  final List<T> items;
  final String Function(T item) labelBuilder;

  /// Valor controlado
  final T? value;

  /// Valor inicial (útil para edición)
  final T? initialValue;

  final ValueChanged<T?>? onChanged;

  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final Widget? prefixIcon;

  /// Validador
  final String? Function(T?)? validator;

  /// Validación automática
  final bool autoValidate;

  final bool enabled;

  const XsSelect({
    super.key,
    this.labelText,
    required this.items,
    required this.labelBuilder,
    this.value,
    this.initialValue,
    this.onChanged,
    this.textColor,
    this.borderColor,
    this.borderRadius = 10,
    this.prefixIcon,
    this.validator,
    this.autoValidate = false,
    this.enabled = true,
  });

  OutlineInputBorder getBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = this.borderColor ?? Colors.grey;

    final textColor = this.textColor ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        Colors.black;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField<T>(
        value: value ?? initialValue,

        validator: validator,

        autovalidateMode: autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,

        onChanged: enabled ? onChanged : null,

        style: TextStyle(
          color: textColor,
          fontSize: 14,
        ),

        dropdownColor: Theme.of(context).cardColor,

        decoration: InputDecoration(
          labelText: labelText,

          prefixIcon: prefixIcon,

          enabledBorder: getBorder(borderColor),

          focusedBorder: getBorder(borderColor),

          errorBorder: getBorder(AppColors.red),

          focusedErrorBorder: getBorder(AppColors.red),

          border: getBorder(borderColor),
        ),

        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              labelBuilder(item),
              style: TextStyle(
                color: textColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}