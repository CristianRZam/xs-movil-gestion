import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:app_movil_sistema/features/login/presentation/pages/login_screen.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class XsBottomBar extends StatelessWidget {
  const XsBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tokenStorage = TokenStorage();

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.dark : AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.home, color: Colors.white),
          const Icon(Icons.face, color: Colors.white),
          const Icon(Icons.build, color: Colors.white),
          GestureDetector(
            onTap: () async {
              // Eliminar token
              await tokenStorage.deleteToken();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
