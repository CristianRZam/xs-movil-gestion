import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class XsText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final FontStyle? fontStyle;
  final bool useDarkModeColor;

  const XsText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textAlign = TextAlign.start,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.fontStyle,
    this.useDarkModeColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color resolvedColor =
    useDarkModeColor && isDarkMode ? Colors.white : (color ?? AppColors.primary);

    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: resolvedColor,
        decoration: decoration,
        fontStyle: fontStyle,
      ),
    );
  }
}
