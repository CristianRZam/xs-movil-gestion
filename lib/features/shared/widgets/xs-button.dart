import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';

enum XsButtonMode { filled, outlined }

class XsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final XsButtonMode mode;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final double width;
  final bool uppercase;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const XsButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.mode = XsButtonMode.filled,
    this.color,
    this.textColor,
    this.borderRadius = 10,
    this.width = double.infinity,
    this.uppercase = true,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = color ?? AppColors.primary;
    final Color effectiveTextColor =
        textColor ?? (mode == XsButtonMode.filled ? Colors.white : baseColor);

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: mode == XsButtonMode.filled ? baseColor : Colors.transparent,
          side: BorderSide(color: baseColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
        ),
        child: Text(
          uppercase ? text.toUpperCase() : text,
          style: TextStyle(
            color: effectiveTextColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
