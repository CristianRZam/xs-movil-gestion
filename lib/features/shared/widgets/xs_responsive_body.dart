import 'package:flutter/widgets.dart';

/// Centra el contenido de lectura en tablet/escritorio sin cambiar su flujo
/// en teléfonos. Los formularios o selectores que requieran pantalla completa
/// no deben envolverse con este widget.
class XsResponsiveBody extends StatelessWidget {
  const XsResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth <= maxWidth) return child;
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: maxWidth, child: child),
      );
    },
  );
}
