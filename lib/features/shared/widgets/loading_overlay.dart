import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          strokeWidth: 8,
                          color: AppColors.grey.withAlpha(140),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
