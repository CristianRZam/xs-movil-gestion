import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum FlashMessageType { error, success, warning, info }
enum FlashMessagePosition { top, center, bottom }

class FlashMessage {
  static OverlayEntry? _currentOverlay;

  static void show(
      BuildContext context, {
        FlashMessageType type = FlashMessageType.error,
        String title = "Error",
        String message = "Algo salió mal.",
        FlashMessagePosition position = FlashMessagePosition.bottom,
      }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    if (_currentOverlay != null && _currentOverlay!.mounted) {
      return;
    }

    final config = _getConfig(type);
    final snackBarColor = config["color"] as Color;
    final icon = config["icon"] as IconData;

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalMargin = 16.0;
    final contentWidth = screenWidth - 2 * horizontalMargin;
    late OverlayEntry overlayEntry;

    void closeMessage() {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        _currentOverlay = null;
      }
    }

    double? top;
    double? bottom;
    if (position == FlashMessagePosition.top) {
      top = 40;
    } else if (position == FlashMessagePosition.center) {
      top = MediaQuery.of(context).size.height / 2 - 80;
    } else {
      bottom = 40;
    }

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: closeMessage, // Cierra si se toca fuera
        child: Stack(
          children: [
            Positioned(
              top: top,
              bottom: bottom,
              left: horizontalMargin,
              right: horizontalMargin,
              child: GestureDetector(
                onTap: () {}, // Evita que el tap dentro cierre el mensaje
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: contentWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [snackBarColor.withOpacity(0.9), snackBarColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: snackBarColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                shadows: [Shadow(color: Colors.black26, blurRadius: 3)],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message,
                              style: const TextStyle(fontSize: 14, color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: closeMessage,
                          child: const Icon(Icons.close, color: AppColors.white, size: 18),
                        ),
                      ),
                      Positioned(
                        top: -22,
                        left: 12,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: snackBarColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: snackBarColor.withOpacity(0.6),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;

    Future.delayed(const Duration(seconds: 3), closeMessage);
  }

  static Map<String, dynamic> _getConfig(FlashMessageType type) {
    switch (type) {
      case FlashMessageType.success:
        return {"color": Colors.green, "icon": FontAwesomeIcons.circleCheck};
      case FlashMessageType.warning:
        return {"color": Colors.orange, "icon": FontAwesomeIcons.triangleExclamation};
      case FlashMessageType.info:
        return {"color": Colors.blue, "icon": FontAwesomeIcons.circleInfo};
      default:
        return {"color": const Color(0xFFD64545), "icon": FontAwesomeIcons.circleExclamation};
    }
  }
}
