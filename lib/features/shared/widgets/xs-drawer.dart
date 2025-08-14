import 'package:app_movil_sistema/features/shared/widgets/xs-dash-line.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-text.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/routes/routes.dart';

class XsDrawer extends StatelessWidget {
  const XsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: isDarkMode ? AppColors.dark : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const XsText(
                  text: 'EmpreGestion',
                  fontSize: 24,
                  color: AppColors.white,
                  useDarkModeColor: true,
                ),
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 30), // margen izquierdo
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBody : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ListView(
                children: [
                  XsText(
                    text: '➤ MÁS OPCIONES',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    useDarkModeColor: true,
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(7, (i) {
                    final titulos = [
                      "01 / Ser una emprendedora",
                      "02 / De la idea al negocio",
                      "03 / Finanzas para tu negocio",
                      "04 / Logística y abastecimiento",
                      "05 / Marketing",
                      "06 / Ventas",
                      "07 / Plan de negocio",
                    ];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(Icons.arrow_right, size: 28, color: isDarkMode ? AppColors.white : AppColors.primary),
                          title: Text(
                            titulos[i],
                            style: TextStyle(fontSize: 14, color: isDarkMode ? AppColors.white : AppColors.dark),
                          ),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: DashedLine(
                            dashWidth: 6,
                            dashSpace: 5,
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // Pie con logo
          Container(
            color: isDarkMode ? AppColors.dark : AppColors.primary,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: const Text(
              '© empresa',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
