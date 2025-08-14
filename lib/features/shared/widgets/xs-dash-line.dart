import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  const DashedLine({
    this.height = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.color = Colors.black26,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
