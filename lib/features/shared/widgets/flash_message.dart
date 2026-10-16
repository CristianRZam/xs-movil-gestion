import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum FlashMessageType { error, success, warning, info }

enum FlashMessagePosition { top, center, bottom }

class FlashMessage {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    FlashMessageType type = FlashMessageType.error,
    String title = '',
    String message = '',
    FlashMessagePosition position = FlashMessagePosition.top,
  }) {
    // Una respuesta HTTP puede llegar justo cuando el coordinador elimina la
    // ruta por cierre de sesión. En ese instante el contexto anterior está
    // desactivado y no se debe resolver ningún ancestro desde él.
    if (!context.mounted) return;
    OverlayState? overlay;
    try {
      overlay = Overlay.maybeOf(context, rootOverlay: true);
    } catch (_) {
      return;
    }
    if (overlay == null) return;

    showOnOverlay(
      overlay,
      context: context,
      type: type,
      title: title,
      message: message,
      position: position,
    );
  }

  static void showOnOverlay(
    OverlayState overlay, {
    required BuildContext context,
    FlashMessageType type = FlashMessageType.error,
    String title = '',
    String message = '',
    FlashMessagePosition position = FlashMessagePosition.top,
  }) {
    if (!overlay.mounted) return;
    if (_currentOverlay?.mounted ?? false) {
      _currentOverlay?.remove();
      _currentOverlay = null;
    }

    final config = _getConfig(type);

    // El overlay del Navigator raíz permanece estable aunque la pantalla que
    // originó el mensaje haya sido retirada de la pila.
    final overlayContext = overlay.context;
    final theme = Theme.of(overlayContext);
    final isDark = theme.brightness == Brightness.dark;

    late OverlayEntry overlayEntry;

    void close() {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        _currentOverlay = null;
      }
    }

    double? top;
    double? bottom;

    switch (position) {
      case FlashMessagePosition.top:
        top = 60;
        break;

      case FlashMessagePosition.center:
        top = MediaQuery.of(overlayContext).size.height * .40;
        break;

      case FlashMessagePosition.bottom:
        bottom = 40;
        break;
    }

    overlayEntry = OverlayEntry(
      builder: (_) => _FlashMessageWidget(
        title: title,
        message: message,
        icon: config.icon,
        accentColor: config.color,
        isDark: isDark,
        top: top,
        bottom: bottom,
        onClose: close,
      ),
    );

    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;

  }

  static _FlashConfig _getConfig(FlashMessageType type) {
    switch (type) {
      case FlashMessageType.success:
        return _FlashConfig(
          color: const Color(0xFF22C55E),
          icon: FontAwesomeIcons.circleCheck,
        );

      case FlashMessageType.warning:
        return _FlashConfig(
          color: const Color(0xFFF59E0B),
          icon: FontAwesomeIcons.triangleExclamation,
        );

      case FlashMessageType.info:
        return _FlashConfig(
          color: const Color(0xFF3B82F6),
          icon: FontAwesomeIcons.circleInfo,
        );

      case FlashMessageType.error:
        return _FlashConfig(
          color: const Color(0xFFEF4444),
          icon: FontAwesomeIcons.circleExclamation,
        );
    }
  }
}

class _FlashConfig {
  final Color color;
  final FaIconData icon;

  const _FlashConfig({required this.color, required this.icon});
}

class _FlashMessageWidget extends StatefulWidget {
  final String title;
  final String message;
  final FaIconData icon;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onClose;

  final double? top;
  final double? bottom;

  const _FlashMessageWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.onClose,
    this.top,
    this.bottom,
  });

  @override
  State<_FlashMessageWidget> createState() => _FlashMessageWidgetState();
}

class _FlashMessageWidgetState extends State<_FlashMessageWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _durationController;

  late Animation<Offset> _slide;

  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _durationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _slide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _durationController
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          widget.onClose();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDark
        ? const Color(0xAE1A2024)
        : const Color(0xB3FFFFFF);

    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: .42),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .14),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: FaIcon(
                                  widget.icon,
                                  size: 18,
                                  color: widget.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: textColor.withValues(alpha: .80),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: widget.onClose,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: textColor.withValues(alpha: .65),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _durationController,
                        builder: (context, _) => LinearProgressIndicator(
                          value: 1 - _durationController.value,
                          minHeight: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.accentColor.withValues(alpha: .92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
