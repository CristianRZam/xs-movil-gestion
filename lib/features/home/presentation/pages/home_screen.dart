import 'package:app_movil_sistema/features/shared/widgets/xs-bottom-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:flutter/services.dart'; // Para SystemNavigator.pop()

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();

    return FutureBuilder<String?>(
      future: tokenStorage.getToken(),
      builder: (context, snapshot) {
        final hasToken = snapshot.hasData && snapshot.data != null;

        return WillPopScope(
          onWillPop: () async {
            // Si hay token, salir de la app
            if (hasToken) {
              SystemNavigator.pop();
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: const XsAppBar(title: 'Home', backIcon: false),
            endDrawer: const XsDrawer(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hola',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    // Mostrar token
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) ...[
                      const CircularProgressIndicator(),
                    ] else if (!hasToken) ...[
                      const Text(
                        'No hay token guardado',
                        style: TextStyle(color: Colors.red),
                      ),
                    ] else ...[
                      Text(
                        'Token: ${snapshot.data}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const XsBottomBar(),
          ),
        );
      },
    );
  }
}
