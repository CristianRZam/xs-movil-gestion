import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';


class XsDialog extends StatelessWidget {

  final String title;

  final Widget child;

  final String cancelText;

  final String confirmText;

  final VoidCallback? onConfirm;

  final VoidCallback? onCancel;

  final bool showCancelButton;

  final bool showConfirmButton;

  final bool loading;


  const XsDialog({

    super.key,

    required this.title,

    required this.child,

    this.cancelText = "Cancelar",

    this.confirmText = "Guardar",

    this.onConfirm,

    this.onCancel,

    this.showCancelButton = true,

    this.showConfirmButton = true,

    this.loading = false,

  });



  @override
  Widget build(BuildContext context) {


    return Dialog(

      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,

      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),


      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(20),

      ),



      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [


            Text(

              title,

              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),

            ),


            const SizedBox(height: 20),



            Flexible(

              child: SingleChildScrollView(

                child: child,

              ),

            ),



            const SizedBox(height: 24),



            Row(

              mainAxisAlignment: MainAxisAlignment.end,

              children: [


                if(showCancelButton)

                  TextButton(

                    onPressed: loading
                        ? null
                        : (){

                      Navigator.pop(context);

                      onCancel?.call();

                    },


                    child: Text(
                      cancelText,
                    ),

                  ),



                const SizedBox(width: 10),



                if(showConfirmButton)

                  ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: AppColors.primary,

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(12),

                      ),

                    ),


                    onPressed: loading
                        ? null
                        : onConfirm,


                    child: loading

                        ? const SizedBox(

                      width: 20,

                      height: 20,

                      child: CircularProgressIndicator(

                        strokeWidth: 2,

                        color: Colors.white,

                      ),

                    )

                        :

                    Text(
                      confirmText,
                    ),

                  ),


              ],

            )


          ],

        ),

      ),

    );

  }
}