import 'package:flutter/material.dart';

import 'conditional_builder.dart';

class BaiomyToast {
  static OverlayEntry? _currentToast;
  static OverlayEntry? _loadingToast;

  /// Show success toast
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const .new(seconds: 3),
    ToastPosition position = .top,
  }) {
    _showToast(
      context,
      message: message,
      type: .success,
      duration: duration,
      position: position,
    );
  }

  /// Show error toast
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const .new(seconds: 4),
    ToastPosition position = .bottom,
  }) {
    _showToast(
      context,
      message: message,
      type: .error,
      duration: duration,
      position: position,
    );
  }

  /// Show warning toast
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const .new(seconds: 3),
    ToastPosition position = .top,
  }) {
    _showToast(
      context,
      message: message,
      type: .warning,
      duration: duration,
      position: position,
    );
  }

  /// Show info toast
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const .new(seconds: 3),
    ToastPosition position = .top,
  }) {
    _showToast(
      context,
      message: message,
      type: .info,
      duration: duration,
      position: position,
    );
  }

  /// Show loading toast (doesn't auto-dismiss)
  static void loading(
    BuildContext context,
    String message, {
    ToastPosition position = .center,
  }) {
    hideLoading(); // Hide any existing loading
    _loadingToast = _createOverlayEntry(
      message: message,
      type: ToastType.loading,
      position: position,
      isLoading: true,
    );
    Overlay.of(context).insert(_loadingToast!);
  }

  /// Hide loading toast
  static void hideLoading() {
    _loadingToast?.remove();
    _loadingToast = null;
  }

  /// Hide current toast
  static void hide() {
    _currentToast?.remove();
    _currentToast = null;
  }

  /// Hide all toasts
  static void hideAll() {
    hide();
    hideLoading();
  }

  static void _showToast(
    BuildContext context, {
    required String message,
    required ToastType type,
    required Duration duration,
    required ToastPosition position,
  }) {
    // Remove existing toast
    _currentToast?.remove();

    _currentToast = _createOverlayEntry(
      message: message,
      type: type,
      position: position,
    );

    Overlay.of(context).insert(_currentToast!);

    // Auto dismiss after duration
    Future<void>.delayed(duration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

  static OverlayEntry _createOverlayEntry({
    required String message,
    required ToastType type,
    required ToastPosition position,
    bool isLoading = false,
  }) => OverlayEntry(
    builder: (BuildContext context) => _ToastWidget(
      message: message,
      type: type,
      position: position,
      isLoading: isLoading,
    ),
  );
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final bool isLoading;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
    this.isLoading = false,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = .new(duration: const .new(milliseconds: 300), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: _getSlideOffset(),
      end: .zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  Offset _getSlideOffset() => switch (widget.position) {
    .top => const .new(0, -1),
    .bottom => const .new(0, 1),
    .center => const .new(0, 0.3),
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == .top ? 50 : null,
      bottom: widget.position == .bottom ? 50 : null,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const .symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: .circular(12),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 10,
                    offset: const .new(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: .min,
                children: <Widget>[
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: .new(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: .w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() => BaiomyConditionalBuilder(
    condition: widget.isLoading,
    builder: (BuildContext context) => const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
    fallback: (BuildContext context) {
      IconData iconData;
      switch (widget.type) {
        case ToastType.success:
          iconData = Icons.check_circle;
        case ToastType.error:
          iconData = Icons.error;
        case ToastType.warning:
          iconData = Icons.warning;
        case ToastType.info:
          iconData = Icons.info;
        case ToastType.loading:
          iconData = Icons.hourglass_empty;
      }

      return Icon(iconData, color: Colors.white, size: 20);
    },
  );

  Color _getBackgroundColor() => switch (widget.type) {
    .success => const Color(0xFF10B981), // Green
    .error => const Color(0xFFEF4444), // Red
    .warning => const Color(0xFFF59E0B), // Orange
    .info => const Color(0xFF3B82F6), // Blue
    .loading => const Color(0xFF6B7280), // Gray
  };
}

enum ToastType { success, error, warning, info, loading }

enum ToastPosition { top, center, bottom }
