import 'package:app_movil_sistema/features/shared/widgets/flash_message.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-bottom-bar.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-drawer.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/features/shared/widgets/xs-app-bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const XsAppBar(title: 'EmpreGestion'),
      endDrawer: const XsDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Hola',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const XsBottomBar(),
    );
  }
}
