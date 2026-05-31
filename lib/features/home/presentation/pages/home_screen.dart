import 'package:app_movil_sistema/features/home/presentation/widgets/dashboard_card.dart';
import 'package:app_movil_sistema/features/home/presentation/widgets/dashboard_sale_analityc.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-bottom-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:flutter/services.dart';

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
            if (hasToken) {
              SystemNavigator.pop();
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: const XsAppBar(title: 'Dashboard', backIcon: false),
            endDrawer: const XsDrawer(),
            body: const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    DashboardGrid(),
                    SizedBox(height: 16),
                    DashboardSaleAnalytic(),
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
