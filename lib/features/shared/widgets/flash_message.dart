import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum FlashMessageType {
  error,
  success,
  warning,
  info,
}

enum FlashMessagePosition {
  top,
  center,
  bottom,
}

class FlashMessage {
  static OverlayEntry? _currentOverlay;

  static void show(
      BuildContext context, {
        FlashMessageType type = FlashMessageType.error,
        String title = '',
        String message = '',
        FlashMessagePosition position = FlashMessagePosition.bottom,
      }) {
    final overlay = Overlay.of(context);

    if (overlay == null) return;

    if (_currentOverlay?.mounted ?? false) {
      _currentOverlay?.remove();
      _currentOverlay = null;
    }

    final config = _getConfig(type);

    final theme = Theme.of(context);
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
        top = MediaQuery.of(context).size.height * .40;
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

    Future.delayed(
      const Duration(seconds: 4),
      close,
    );
  }

  static _FlashConfig _getConfig(
      FlashMessageType type,
      ) {
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
  final FaIconData  icon;

  const _FlashConfig({
    required this.color,
    required this.icon,
  });
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
  State<_FlashMessageWidget> createState() =>
      _FlashMessageWidgetState();
}
class _FlashMessageWidgetState
    extends State<_FlashMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _slide;

  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _slide = Tween(
      begin: const Offset(
        0,
        0.15,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDark
        ? const Color(0xFF1C1C1E)
        : Colors.white;

    final textColor =
    widget.isDark ? Colors.white : Colors.black87;

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
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.accentColor.withOpacity(.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 20,
                    offset: const Offset(
                      0,
                      10,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: widget.accentColor
                            .withOpacity(.12),
                        borderRadius:
                        BorderRadius.circular(12),
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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: textColor
                                  .withOpacity(.75),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    InkWell(
                      borderRadius:
                      BorderRadius.circular(100),
                      onTap: widget.onClose,
                      child: Padding(
                        padding:
                        const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: textColor
                              .withOpacity(.55),
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
    );
  }
}