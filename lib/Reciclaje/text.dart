import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class XsTextField extends StatefulWidget {
  final String? labelText;
  final bool isPassword;
  final TextEditingController? controller;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool autoValidate;
  final bool useWhiteInDarkMode;

  const XsTextField({
    super.key,
    this.labelText,
    this.isPassword = false,
    this.controller,
    this.textColor,
    this.borderColor,
    this.borderRadius = 10,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.autoValidate = false,
    this.useWhiteInDarkMode = false,
  });

  @override
  State<XsTextField> createState() => _XsTextFieldState();
}

class _XsTextFieldState extends State<XsTextField> {
  bool _obscureText = true;

  OutlineInputBorder getBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 1.5),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldUseWhite = isDark && widget.useWhiteInDarkMode;

    final borderColor = widget.borderColor ?? Colors.grey;
    final effectiveTextColor = shouldUseWhite ? Colors.white : widget.textColor;
    final effectiveIconColor = shouldUseWhite ? Colors.white : AppColors.grey;
    final floatingLabelColor = shouldUseWhite ? Colors.white : borderColor;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        style: TextStyle(color: effectiveTextColor),
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        onSaved: widget.onSaved,
        onChanged: widget.onChanged,
        autovalidateMode: widget.autoValidate ? AutovalidateMode.onUserInteraction : null,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(color: floatingLabelColor),
          prefixIcon: widget.prefixIcon != null
              ? IconTheme(
            data: IconThemeData(color: effectiveIconColor),
            child: widget.prefixIcon!,
          )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: effectiveIconColor,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : (widget.suffixIcon != null
              ? IconTheme(
            data: IconThemeData(color: effectiveIconColor),
            child: widget.suffixIcon!,
          )
              : null),
          enabledBorder: getBorder(shouldUseWhite ? Colors.white : borderColor),
          focusedBorder: getBorder(borderColor),
          errorBorder: getBorder(AppColors.red),
          focusedErrorBorder: getBorder(AppColors.red),
          border: getBorder(borderColor),
        ),
      ),
    );
  }
}
