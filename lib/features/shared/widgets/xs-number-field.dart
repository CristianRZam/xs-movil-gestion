import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class XsNumberField extends StatelessWidget {

  final String? labelText;
  final TextEditingController? controller;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final Widget? prefixIcon;
  final bool decimal;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;


  const XsNumberField({

    super.key,

    this.labelText,

    this.controller,

    this.textColor,

    this.borderColor,

    this.borderRadius = 10,

    this.prefixIcon,

    this.decimal = false,

    this.validator,

    this.onChanged,
    this.readOnly = false,

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


    return Padding(

      padding: const EdgeInsets.only(top: 16),

      child: TextFormField(

        controller: controller,
        readOnly: readOnly,


        keyboardType: decimal

            ? const TextInputType.numberWithOptions(
          decimal: true,
        )

            : TextInputType.number,



        inputFormatters: [

          FilteringTextInputFormatter.allow(

            decimal

                ? RegExp(r'^\d*\.?\d*')

                : RegExp(r'^\d*'),

          ),

        ],



        style: TextStyle(

          color: textColor,

        ),



        validator: validator,

        onChanged: onChanged,



        decoration: InputDecoration(

          labelText: labelText,

          prefixIcon: prefixIcon,


          enabledBorder: getBorder(borderColor),

          focusedBorder: getBorder(borderColor),

          errorBorder: getBorder(AppColors.red),

          focusedErrorBorder: getBorder(AppColors.red),

          border: getBorder(borderColor),

        ),

      ),

    );

  }

}
